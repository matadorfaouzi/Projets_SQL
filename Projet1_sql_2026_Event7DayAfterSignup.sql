/*
===============================================================================
PROJET : ANALYSE DE LA RÉTENTION DES UTILISATEURS À J+7
SGBD    : Microsoft SQL Server
NIVEAU  : Débutant à intermédiaire
OBJECTIF:
Analyser l'activité des utilisateurs après leur inscription et mesurer la
rétention à J+7, c'est-à-dire vérifier si un utilisateur a réalisé au moins
un événement exactement sept jours après sa date d'inscription.

TABLES:
- dbo.users  : un enregistrement par utilisateur, avec sa date d'inscription.
- dbo.events : les événements réalisés par les utilisateurs.

NOTION IMPORTANTE:
Dans ce projet, la rétention à J+7 signifie qu'un événement existe exactement
à la date signup_date + 7 jours. Ce n'est pas la même chose qu'un événement
survenu à partir du septième jour.
===============================================================================
*/

/*-----------------------------------------------------------------------------
ÉTAPE 1 — Réinitialiser l'environnement de test
Objectif : supprimer les tables du projet si elles existent déjà afin de
pouvoir relancer le script sans conserver les anciennes données.
Attention : cette opération supprime les données présentes dans ces tables.
-----------------------------------------------------------------------------*/
DROP TABLE IF EXISTS dbo.events;
DROP TABLE IF EXISTS dbo.users;


/*-----------------------------------------------------------------------------
ÉTAPE 2 — Créer la table des utilisateurs
Objectif : stocker l'identifiant unique de chaque utilisateur et sa date
d'inscription.
Notions SQL : CREATE TABLE, clé primaire (PRIMARY KEY), contrainte NOT NULL.
-----------------------------------------------------------------------------*/
CREATE TABLE dbo.users (
    user_id INT PRIMARY KEY,
    signup_date DATE NOT NULL
);


/*-----------------------------------------------------------------------------
ÉTAPE 3 — Créer la table des événements
Objectif : enregistrer les événements réalisés par les utilisateurs.
Notions SQL : IDENTITY pour générer event_id, clé primaire et clé étrangère.
La clé étrangère garantit qu'un événement est associé à un utilisateur
présent dans dbo.users.
-----------------------------------------------------------------------------*/
CREATE TABLE dbo.events (
    event_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    event_date DATE NOT NULL,
    event_type VARCHAR(30) NOT NULL,

    CONSTRAINT FK_events_users
        FOREIGN KEY (user_id)
        REFERENCES dbo.users(user_id)
);


/*-----------------------------------------------------------------------------
ÉTAPE 4 — Insérer les utilisateurs de test
Objectif : créer un petit jeu de données couvrant plusieurs dates
d'inscription, notamment en janvier et février 2025.
Ces données permettront de tester les filtres temporels et la rétention.
-----------------------------------------------------------------------------*/
INSERT INTO dbo.users (user_id, signup_date)
VALUES
    (101, '20250103'),
    (102, '20250108'),
    (103, '20250115'),
    (104, '20250202'),
    (105, '20250210'),
    (106, '20250218'),
    (107, '20250305');


/*-----------------------------------------------------------------------------
ÉTAPE 5 — Insérer les événements de test
Objectif : simuler différentes activités : consultation de page, clic et achat.
Certains utilisateurs ont plusieurs événements le même jour ; cela permettra
de distinguer le nombre d'événements du nombre d'utilisateurs actifs.
-----------------------------------------------------------------------------*/
INSERT INTO dbo.events (user_id, event_date, event_type)
VALUES
    (101, '20250110', 'page_view'),
    (101, '20250110', 'click'),
    (101, '20250110', 'purchase'),

    (102, '20250114', 'page_view'),
    (102, '20250115', 'click'),

    (103, '20250120', 'page_view'),
    (103, '20250121', 'click'),
    (103, '20250122', 'purchase'),

    (104, '20250209', 'page_view'),
    (105, '20250217', 'purchase'),
    (106, '20250225', 'click'),
    (107, '20250312', 'page_view');


/*-----------------------------------------------------------------------------
ÉTAPE 6 — Vérifier le contenu des tables
Objectif : contrôler les données insérées avant de commencer l'analyse.
Notions SQL : SELECT, ORDER BY.
Le tri facilite la vérification des utilisateurs et de leurs événements.
-----------------------------------------------------------------------------*/
SELECT *
FROM dbo.users
ORDER BY user_id;

SELECT *
FROM dbo.events
ORDER BY user_id, event_date, event_id;


/*-----------------------------------------------------------------------------
ÉTAPE 7 — Première jointure entre utilisateurs et événements
Objectif : associer chaque événement à l'utilisateur qui l'a réalisé.
Notion SQL : INNER JOIN sur la colonne user_id.
Attention : seuls les utilisateurs ayant au moins un événement apparaissent
dans le résultat d'une jointure interne.
-----------------------------------------------------------------------------*/
SELECT *
FROM dbo.users AS u
INNER JOIN dbo.events AS e
    ON u.user_id = e.user_id;


/*-----------------------------------------------------------------------------
ÉTAPE 7 bis — Afficher les informations utiles après la jointure
Objectif : obtenir une vue lisible avec l'identifiant de l'utilisateur,
sa date d'inscription, la date de l'événement et son type.
Notions SQL : sélection de colonnes, alias de tables et ORDER BY.
-----------------------------------------------------------------------------*/
SELECT
    u.user_id,
    u.signup_date,
    e.event_date,
    e.event_type
FROM dbo.users AS u
INNER JOIN dbo.events AS e
    ON u.user_id = e.user_id
ORDER BY u.user_id, e.event_date;


/*-----------------------------------------------------------------------------
ÉTAPE 8 — Calculer la date J+7 pour les inscriptions de janvier 2025
Objectif : déterminer la date correspondant à sept jours après l'inscription
de chaque utilisateur inscrit en janvier 2025.
Notions SQL : DATEADD et filtre de dates avec une borne de début incluse
et une borne de fin exclue.
-----------------------------------------------------------------------------*/
SELECT
    user_id,
    signup_date,
    DATEADD(DAY, 7, signup_date) AS date_j7
FROM dbo.users
WHERE signup_date >= '20250101'
  AND signup_date <  '20250201'
ORDER BY user_id;


/*-----------------------------------------------------------------------------
ÉTAPE 9 — Trouver les événements survenus au moins sept jours après
l'inscription
Objectif : afficher les événements réalisés à J+7 ou plus tard.
Notion SQL : DATEDIFF pour calculer le nombre de changements de jour entre
la date d'inscription et la date de l'événement.
À distinguer de la rétention exacte à J+7 : cette requête inclut aussi les
événements survenus après le septième jour.
-----------------------------------------------------------------------------*/
SELECT
    e.event_id,
    e.user_id,
    DATEDIFF(DAY, u.signup_date, e.event_date) AS difference_date,
    e.event_type
FROM dbo.users AS u
INNER JOIN dbo.events AS e
    ON u.user_id = e.user_id
WHERE DATEDIFF(DAY, u.signup_date, e.event_date) >= 7;


/*-----------------------------------------------------------------------------
ÉTAPE 10 — Compter les utilisateurs inscrits en janvier 2025
Objectif : calculer la taille de la cohorte de janvier, qui servira de base
au calcul du taux de rétention.
Bonne pratique : filtrer une colonne DATE avec un intervalle plutôt qu'avec
LIKE, afin d'exprimer clairement les bornes temporelles.
-----------------------------------------------------------------------------*/
SELECT COUNT(*) AS total_users_january
FROM dbo.users
WHERE signup_date >= '20250101'
  AND signup_date <  '20250201';


/*-----------------------------------------------------------------------------
ÉTAPE 11 — Identifier les utilisateurs ayant un événement exactement à J+7
parmi les inscriptions de janvier 2025
Objectif : afficher les événements dont la date correspond exactement à
la date d'inscription augmentée de sept jours.
Notions SQL : INNER JOIN, DATEADD et filtrage par intervalle de dates.
Cette requête retourne les événements correspondants ; un utilisateur peut
apparaître plusieurs fois s'il a plusieurs événements à cette date.
-----------------------------------------------------------------------------*/
SELECT
    u.user_id,
    u.signup_date,
    e.event_date,
    e.event_type
FROM dbo.users AS u
INNER JOIN dbo.events AS e
    ON e.user_id = u.user_id
WHERE u.signup_date >= '20250101'
  AND u.signup_date <  '20250201'
  AND e.event_date = DATEADD(DAY, 7, u.signup_date);


/*-----------------------------------------------------------------------------
ÉTAPE 12 — Attribuer un statut de rétention à chaque utilisateur de janvier
Objectif : conserver tous les utilisateurs de la cohorte et indiquer si au
moins un événement existe exactement à J+7.
Notions SQL : CASE WHEN et EXISTS.
EXISTS vérifie l'existence d'au moins une ligne sans multiplier les
utilisateurs lorsqu'ils possèdent plusieurs événements le même jour.
-----------------------------------------------------------------------------*/
SELECT
    u.user_id,
    u.signup_date,
    DATEADD(DAY, 7, u.signup_date) AS date_j7,
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM dbo.events AS e
            WHERE e.user_id = u.user_id
              AND e.event_date = DATEADD(DAY, 7, u.signup_date)
        )
        THEN 'Retenu'
        ELSE 'Non retenu'
    END AS retention_status
FROM dbo.users AS u
WHERE u.signup_date >= '20250101'
  AND u.signup_date <  '20250201'
ORDER BY u.user_id;


/*-----------------------------------------------------------------------------
ÉTAPE 13 — Calculer le taux global de rétention à J+7
Objectif : mesurer la proportion d'utilisateurs inscrits en janvier qui ont
réalisé au moins un événement exactement sept jours après leur inscription.
Méthode :
1. La CTE UserRetention calcule un indicateur binaire par utilisateur.
2. SUM(is_retained) compte les utilisateurs retenus.
3. COUNT(*) compte les utilisateurs de la cohorte.
4. Le résultat est exprimé en pourcentage avec deux décimales.
NULLIF évite une division par zéro si la cohorte est vide.
-----------------------------------------------------------------------------*/
WITH UserRetention AS (
    SELECT
        u.user_id,
        CASE
            WHEN EXISTS (
                SELECT 1
                FROM dbo.events AS e
                WHERE e.user_id = u.user_id
                  AND e.event_date = DATEADD(DAY, 7, u.signup_date)
            )
            THEN 1
            ELSE 0
        END AS is_retained
    FROM dbo.users AS u
    WHERE u.signup_date >= '20250101'
      AND u.signup_date <  '20250201'
)
SELECT
    COUNT(*) AS total_users,
    SUM(is_retained) AS retained_users,
    CAST(
        100.0 * SUM(is_retained) / NULLIF(COUNT(*), 0)
        AS DECIMAL(5,2)
    ) AS retention_pct
FROM UserRetention;


/*-----------------------------------------------------------------------------
ÉTAPE 14 — Afficher le détail de la CTE de rétention
Objectif : inspecter le résultat intermédiaire utilisateur par utilisateur
avant de produire des statistiques globales.
La CTE UserRetention calcule la date J+7 et l'indicateur is_retained.
Cette étape facilite la validation des résultats et le débogage de la requête.
-----------------------------------------------------------------------------*/
WITH UserRetention AS (
    SELECT
        u.user_id,
        u.signup_date,
        DATEADD(DAY, 7, u.signup_date) AS date_j7,
        CASE
            WHEN EXISTS (
                SELECT 1
                FROM dbo.events AS e
                WHERE e.user_id = u.user_id
                  AND e.event_date = DATEADD(DAY, 7, u.signup_date)
            )
            THEN 1
            ELSE 0
        END AS is_retained
    FROM dbo.users AS u
    WHERE u.signup_date >= '20250101'
      AND u.signup_date <  '20250201'
)
SELECT *
FROM UserRetention
ORDER BY user_id;


/*-----------------------------------------------------------------------------
ÉTAPE 15 — Calculer un taux de rétention à partir d'une jointure
Objectif : calculer le ratio entre les événements trouvés à J+7 et le nombre
d'utilisateurs inscrits en janvier.
Limite pédagogique : cette version peut compter plusieurs fois un même
utilisateur s'il a plusieurs événements à J+7. Elle mesure alors un ratio
d'événements par utilisateur de la cohorte, et pas nécessairement un taux
de rétention utilisateur.
Pour mesurer la rétention utilisateur, préférer EXISTS ou une liste DISTINCT
des utilisateurs actifs à J+7, comme dans l'étape 16.
-----------------------------------------------------------------------------*/
SELECT
    COUNT(*) * 1.0 / NULLIF(
        (
            SELECT COUNT(*)
            FROM dbo.users
            WHERE signup_date >= '20250101'
              AND signup_date <  '20250201'
        ),
        0
    ) AS event_to_cohort_ratio
FROM dbo.users AS u
INNER JOIN dbo.events AS e
    ON e.user_id = u.user_id
WHERE u.signup_date >= '20250101'
  AND u.signup_date <  '20250201'
  AND e.event_date = DATEADD(DAY, 7, u.signup_date);


/*-----------------------------------------------------------------------------
ÉTAPE 16 — Calculer la rétention à J+7 avec des CTE successives
Objectif : structurer l'analyse en étapes lisibles et éviter de compter
plusieurs fois les utilisateurs qui ont réalisé plusieurs événements à J+7.
CTE 1 — january_cohort : une ligne par utilisateur inscrit en janvier.
CTE 2 — day7_active : une ligne par utilisateur ayant au moins un événement
à J+7, grâce à DISTINCT.
La LEFT JOIN conserve tous les utilisateurs de la cohorte, y compris ceux
qui n'ont aucun événement à J+7.
COUNT(d.user_id) compte les utilisateurs retenus ; COUNT(*) compte la cohorte.
Le résultat day7_retention est un ratio entre 0 et 1 (ex. 0.25 = 25 %).
-----------------------------------------------------------------------------*/
WITH january_cohort AS (
    -- Une ligne par utilisateur inscrit en janvier 2025.
    SELECT
        user_id,
        signup_date
    FROM dbo.users
    WHERE signup_date >= '20250101'
      AND signup_date <  '20250201'
),
day7_active AS (
    -- Une ligne par utilisateur ayant au moins un événement exactement à J+7.
    SELECT DISTINCT
        e.user_id
    FROM january_cohort AS c
    INNER JOIN dbo.events AS e
        ON e.user_id = c.user_id
       AND e.event_date = DATEADD(DAY, 7, c.signup_date)
)
SELECT
    COUNT(*) AS cohort_size,
    COUNT(d.user_id) AS retained_users,
    1.0 * COUNT(d.user_id) / NULLIF(COUNT(*), 0) AS day7_retention
FROM january_cohort AS c
LEFT JOIN day7_active AS d
    ON d.user_id = c.user_id;
