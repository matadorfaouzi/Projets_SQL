-------------------------------------------
-----------------------Création des tables
-------------------------------------------
create table emp(empno int,
				 ename varchar(20),
				 job varchar(20),
				 mgr int,
				 HIREDATE date,
				 SAL int,
				 COMM int,
				 DEPTNO int);

create table DEPT(DEPTNO int,
                  DNAME varchar(20),
			      LOC  varchar(20));


create table SALGRADE(GRADE int,
                      LOSAL int,
					  HISAL int);
-------------------------------------------
-----------------------Clé primaire
-------------------------------------------
alter table emp alter column empno int not null;
alter table emp add constraint pk_emp primary key(empno);
alter table DEPT alter column DEPTNO int not null;
alter table DEPT add constraint pk_DEPT primary key(DEPTNO);
alter table SALGRADE alter column GRADE int not null;
alter table SALGRADE add constraint pk_SALGRADE primary key(GRADE);
-------------------------------------------
-----------------------Clé étrangère
-------------------------------------------
alter table emp add constraint fk_emp_dept foreign key(DEPTNO) references dept(DEPTNO);
alter table emp add constraint fk_emp_emp foreign key(mgr) references emp(empno);
alter table emp drop constraint fk_emp_emp;
-------------------------------------------
-----------------------Insertion
-------------------------------------------
insert into DEPT(DEPTNO, DNAME, LOC) values(10, 'ACCOUNTING', 'NEW YORK');
insert into DEPT(DEPTNO, DNAME, LOC) values(20, 'RESERCH', 'DALLAS');
insert into DEPT(DEPTNO, DNAME, LOC) values(30, 'SALES', 'CHICAGO');
insert into DEPT(DEPTNO, DNAME, LOC) values(40, 'OPERATIONS', 'BOSTON');

insert into emp(EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, DEPTNO) values (7369, 'SMITH', 'Clerk', 7902, '17/12/1980', 800, 20);
insert into emp(EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO) values (7499, 'ALLEN', 'Salesman', 7698, '20/02/1981', 1600, 300, 30);
insert into emp(EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO) values (7521, 'WARD', 'Salesman', 7698, '22/02/1981', 1250, 500, 30);
insert into emp(EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, DEPTNO) values (7566, 'JONES', 'Manager', 7839, '02/04/1981', 2975, 20);
insert into emp(EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO) values (7654, 'MARTIN', 'Salesman', 7698, '28/09/1981', 1250, 1400, 30);
insert into emp(EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, DEPTNO) values (7698, 'BLAKE', 'Manager', 7839, '01/05/1981', 2850, 30);
insert into emp(EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, DEPTNO) values (7782, 'CLARK', 'Manager', 7839, '09/06/1981', 2450, 10);
insert into emp(EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, DEPTNO) values (7788, 'SCOTT', 'Analyst', 7566, '09/12/1982', 3000, 20);
insert into emp(EMPNO, ENAME, JOB, HIREDATE, SAL, DEPTNO) values (7839, 'KING', 'President', '17/11/1981', 5000, 10);
insert into emp(EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO) values (7844, 'TURNER', 'Salesman', 7698, '08/09/1981', 1500, 0, 30);
insert into emp(EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, DEPTNO) values (7876, 'ADAMS', 'Clerk', 7788, '12/01/1983', 1100, 20);
insert into emp(EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, DEPTNO) values (7900, 'JAMES', 'Clerk', 7698, '03/12/1981', 950, 30);
insert into emp(EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, DEPTNO) values (7902, 'FORD', 'Analyst', 7566, '03/12/1981', 3000, 20);
insert into emp(EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, DEPTNO) values (7934, 'MILLER', 'Clerk', 7782, '23/01/1982', 1300, 10);

insert into SALGRADE(GRADE, LOSAL, HISAL) values(1, 700, 1200);
insert into SALGRADE(GRADE, LOSAL, HISAL) values(2, 1201, 1400);
insert into SALGRADE(GRADE, LOSAL, HISAL) values(3, 1401, 2000);
insert into SALGRADE(GRADE, LOSAL, HISAL) values(4, 2001, 3000);
insert into SALGRADE(GRADE, LOSAL, HISAL) values(5, 3001, 9999);

-------------------------------------------
--1.1-----------Afficher le contenu de chacune des tables de la base de données.
-------------------------------------------
select * from emp
select * from DEpt
select * from SALGRADE

-------------------------------------------
--2-----------Fonctions de fenêtrage SQL
-------------------------------------------
/*Une fonction de fenêtre effectue un calcul sur un ensemble de lignes liées tout en conservant les lignes individuelles dans le résultat.*/

-------------------------------------------
--2.1-----------OVER()
-------------------------------------------
/* La clause OVER() indique à SQL Server qu'une fonction doit être utilisée comme une fonction de fenêtre. 
Elle définit les lignes que la fonction doit prendre en compte et, 
le cas échéant, leur ordre et le cadre de la fenêtre.*/
SELECT
    e.empno,
    e.SAL,
    AVG(e.SAL) OVER () AS Salaire_average_emp
FROM emp as e;
/*
AVG(e.SAL) calcule le salaire moyen.
OVER() indique que la moyenne est calculée sur une fenêtre.
Comme aucune partition n'est spécifiée, toutes les lignes appartiennent à la même fenêtre.
Chaque employé est conservé dans le résultat.
Le résultat attendu contient une ligne par employé, avec le salaire moyen affiché à côté de chaque employé.
*/
-------------------------------------------
--2.2-----------PARTITION BY
-------------------------------------------
/*
PARTITION BY divise les lignes en groupes distincts, appelés partitions. 
Une fonction de fenêtre opère ensuite au sein de chaque partition plutôt que sur l'ensemble des données.
*/
SELECT
    e.DEPTNO,
    e.empno,
    e.SAL,
    AVG(e.SAL) OVER (
        PARTITION BY e.DEPTNO
    ) AS department_average_Salaire
FROM emp e;

--Cette requête répartit les employés par département et calcule le salaire moyen de chaque département. Elle conserve une ligne par employé.

-------------------------------------------
--2.3-----------Trier les lignes à l'intérieur d'une fenêtre
-------------------------------------------
/*
Dans la clause OVER(), ORDER BY détermine l'ordre de traitement des lignes. 
Sa signification dépend de la fonction utilisée.
Pour les fonctions de classement, elle détermine l'ordre du classement. 
Pour des fonctions telles que LAG() et LEAD(),
elle détermine quelle ligne est considérée comme précédente ou suivante.
*/
SELECT
    e.empno,
    e.SAL,
    ROW_NUMBER() OVER (
        ORDER BY e.sal DESC
    ) AS sal_position
FROM emp e;

/*
Le salaire le plus élevé reçoit la position 1, 
le salaire suivant reçoit la position 2, et ainsi de suite.
DESC indique un ordre décroissant, du montant le plus élevé au plus faible. 
ASC indique un ordre croissant, du montant le plus faible au plus élevé.
*/

SELECT 
	e.empno,
	e.ename,
	e.SAL AS votes,
    -- Récupérer le salaire de l'employé suivant
	LEAD(e.SAL) OVER (order by e.SAL) AS votes_next_voter,
    -- Calculer la différence entre les salaires
	LEAD(e.SAL) OVER (ORDER BY e.SAL) - e.SAL AS votes_diff
FROM emp as e;

SELECT 
	e.empno,
	e.ename,
	e.SAL AS votes,
    -- Récupérer le salaire de l'employé suivant
	LAG(e.SAL) OVER (order by e.SAL) AS votes_next_voter,
    -- Calculer la différence entre les salaires
	LAG(e.SAL) OVER (ORDER BY e.SAL) - e.SAL AS votes_diff
FROM emp as e;

SELECT 
    CONCAT(e.empno, ' ', e.ename) AS name,
    e.job,
    e.HIREDATE,
    -- Récupérer la date d'embauche la plus ancienne pour chaque poste
    FIRST_VALUE(e.HIREDATE) 
        OVER (PARTITION BY e.job ORDER BY e.HIREDATE) AS oldest_emp,
    -- Récupérer la date d'embauche la plus récente pour chaque poste
    LAST_VALUE(e.HIREDATE) 
        OVER (
            PARTITION BY e.job 
            ORDER BY e.HIREDATE 
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS youngest_emp
FROM emp AS e;

/*
FIRST_VALUE() : trouver la date d'embauche la plus ancienne.
FIRST_VALUE(e.HIREDATE) 
OVER (PARTITION BY e.job ORDER BY e.HIREDATE) AS oldest_emp


- PARTITION BY e.job : divise les employés en groupes selon leur poste.
- ORDER BY e.HIREDATE : classe les employés du plus ancien au plus récent.
- FIRST_VALUE(e.HIREDATE) : récupère la première date d'embauche de chaque groupe.
Ainsi, tous les employés ayant le même poste obtiennent la date d'embauche la plus ancienne de leur groupe.

LAST_VALUE() : trouver la date d'embauche la plus récente.
LAST_VALUE(e.HIREDATE) 
OVER (
    PARTITION BY e.job 
    ORDER BY e.HIREDATE 
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
) AS youngest_emp


La partie essentielle est :
ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING


Cette clause étend la fenêtre de la première à la dernière ligne de chaque groupe.

Sans cette clause, LAST_VALUE() peut renvoyer la dernière valeur de la fenêtre courante, 
qui n'est pas nécessairement la date la plus récente du poste.

Avec cette clause, la fonction renvoie la date d'embauche la plus récente de chaque groupe.
*/

-------------------------------------------
--2.4-----------Cadres de fenêtre
-------------------------------------------

/*
Un cadre de fenêtre définit le sous-ensemble de lignes d'une partition pris en compte pour la ligne courante. 
Les cadres sont particulièrement utiles avec les fonctions de fenêtre d'agrégation et les fonctions de valeur.
*/

SELECT
    e.HIREDATE,
    e.empno,
    e.SAL,
    SUM(e.SAL) OVER (
        ORDER BY e.HIREDATE, e.empno
        ROWS BETWEEN UNBOUNDED PRECEDING
                 AND CURRENT ROW
    ) AS salaire_total
FROM emp e;

/*
Cette requête calcule le total cumulé des salaires dans l'ordre chronologique des embauches.
- SUM(e.SAL) : additionne les salaires.
- OVER (...) : définit la fenêtre utilisée pour le calcul.
- ORDER BY e.HIREDATE, e.empno : trie les employés par date d'embauche, puis par numéro d'employé en cas d'égalité.
- ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW : calcule la somme depuis la première ligne jusqu'à la ligne courante incluse.
Le total cumulé augmente à chaque ligne en ajoutant le salaire de l'employé courant.
*/

/*
ROW_NUMBER() attribue un numéro séquentiel unique à chaque ligne d'une partition.
Exemple d'utilisation : 
identifier les salaires les plus élevés dans l'entreprise ou dans chaque département.
*/

SELECT
    e.empno,
    e.SAL,
    ROW_NUMBER() OVER (
        ORDER BY e.SAL DESC, e.empno
    ) AS row_number
FROM emp e;

/*
RANK() attribue le même rang aux lignes ayant la même valeur de classement. 
Il laisse des sauts dans le classement après une égalité.
*/

SELECT
    e.empno,
    e.SAL,
    RANK() OVER (
        ORDER BY e.SAL DESC, e.empno
    ) AS row_number
FROM emp e;

/*
DENSE_RANK() attribue le même rang aux valeurs ex æquo, sans saut dans le classement.
*/

SELECT
    e.empno,
    e.SAL,
    DENSE_RANK() OVER (
        ORDER BY e.SAL DESC, e.empno
    ) AS row_number
FROM emp e;

/*
NTILE(n) divise les lignes ordonnées en groupes de taille approximativement égale et attribue à chaque groupe un numéro de 1 à n.

Par exemple, NTILE(4) divise les lignes ordonnées en quatre groupes, souvent appelés quartiles.
*/

SELECT
    e.empno,
    e.SAL,
    NTILE(6) OVER (
        ORDER BY e.SAL DESC, e.empno
    ) AS row_number
FROM emp e;

/*
LAG() récupère une valeur de la ligne précédente.
LEAD() récupère une valeur de la ligne suivante.
*/

SELECT
    e.empno,
    e.ename,
    e.SAL,
    LAG(e.SAL) OVER (
        ORDER BY e.ename, e.empno
    ) AS previous_sal_emp
FROM emp e;

SELECT
    e.empno,
    e.ename,
    e.SAL,
    LEAD(e.SAL) OVER (
        ORDER BY e.ename, e.empno
    ) AS last_sal_emp
FROM emp e;


-------------------------------------------
-- 2.5 ----------- Autres fonctions de fenêtrage utiles
-------------------------------------------
/*
Cette section complète les exemples précédents avec plusieurs fonctions de fenêtrage
utiles en analyse de données et en administration SQL.

COUNT() OVER() : compter les employés sans réduire le nombre de lignes.
MIN() et MAX() OVER() : afficher le salaire minimal et maximal sur chaque département.
PERCENT_RANK() : calculer le rang relatif d'une ligne entre 0 et 1.
CUME_DIST() : calculer la proportion de lignes dont la valeur est inférieure ou égale
à celle de la ligne courante.
*/

-- Nombre d'employés dans chaque département
SELECT
    e.empno,
    e.ename,
    e.DEPTNO,
    COUNT(*) OVER (PARTITION BY e.DEPTNO) AS nombre_employes_dept
FROM emp AS e;

-- Salaires minimal et maximal de chaque département
SELECT
    e.empno,
    e.ename,
    e.DEPTNO,
    e.SAL,
    MIN(e.SAL) OVER (PARTITION BY e.DEPTNO) AS salaire_min_dept,
    MAX(e.SAL) OVER (PARTITION BY e.DEPTNO) AS salaire_max_dept
FROM emp AS e;

-- Rang relatif du salaire dans l'ensemble des employés
SELECT
    e.empno,
    e.ename,
    e.SAL,
    PERCENT_RANK() OVER (ORDER BY e.SAL) AS rang_relatif
FROM emp AS e;

-- Distribution cumulative des salaires
SELECT
    e.empno,
    e.ename,
    e.SAL,
    CUME_DIST() OVER (ORDER BY e.SAL) AS distribution_cumulative
FROM emp AS e;

-- Moyenne mobile sur les trois lignes courantes (ordre chronologique)
SELECT
    e.empno,
    e.ename,
    e.HIREDATE,
    e.SAL,
    AVG(CAST(e.SAL AS decimal(10, 2))) OVER (
        ORDER BY e.HIREDATE, e.empno
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moyenne_mobile_3_lignes
FROM emp AS e;

-- Classement des salaires par département : les ex æquo gardent le même rang.
-- Le tri final par empno sert uniquement à rendre l'affichage stable.
SELECT
    e.empno,
    e.ename,
    e.DEPTNO,
    e.SAL,
    RANK() OVER (
        PARTITION BY e.DEPTNO
        ORDER BY e.SAL DESC
    ) AS rang_salaire_dept
FROM emp AS e
ORDER BY e.DEPTNO, e.empno;

/*
Autres fonctions et notions à étudier :
- SUM(), AVG(), COUNT(), MIN(), MAX() avec OVER() et éventuellement PARTITION BY.
- PERCENTILE_CONT() et PERCENTILE_DISC() pour calculer des percentiles.
- Les cadres ROWS : UNBOUNDED PRECEDING, n PRECEDING, CURRENT ROW,
  n FOLLOWING et UNBOUNDED FOLLOWING.
- Les fonctions de valeur FIRST_VALUE(), LAST_VALUE() et, selon le SGBD,
  NTH_VALUE(). SQL Server ne prend pas en charge NTH_VALUE().
- SQL Server prend en charge ROW_NUMBER(), RANK(), DENSE_RANK(), NTILE(),
  LAG(), LEAD(), FIRST_VALUE(), LAST_VALUE(), PERCENT_RANK(), CUME_DIST(),
  PERCENTILE_CONT() et PERCENTILE_DISC().
*/
