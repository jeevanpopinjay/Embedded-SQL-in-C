/*
 *	Embedded SQL programming in C using PostgreSQL
 *	@Author: Akash Rajendra Ventekar, Jeevan Chandrashekar
*/
#include <stdio.h>
#include <string.h>
//Incorporate SQL's error handling mechansim
EXEC SQL INCLUDE sqlca;

//Error handling mechanism
EXEC SQL WHENEVER SQLERROR sqlprint;

int main(int argc, char* argv[])
{

    int flag = 0, i;
	char *pnoo;
    //Variables that will be used in embedded SQL statements
    EXEC SQL BEGIN DECLARE SECTION;
     	int       dnum;
	char *fname=NULL;
	char *minit=NULL;
	char *lname=NULL;
	char *dname=NULL;
	char *fname1=NULL;
        char *minit1=NULL;
        char *lname1=NULL;
	int depno=0;    
	char *mgrssn=NULL; 
	float salary;	
	char*      mssn=NULL;
    	long int ssn;
	int delete = 0;	
	int update = 0;	
	int insert = 0;
	int pnum;
	int pnumber;	
	float hours;
	float hours1;
	float count_hours;
	int count_emp;
	char *pname=NULL; 
	char      date[12];
    EXEC SQL END DECLARE SECTION;

    //Connect to the database with username and password
    EXEC SQL CONNECT TO unix:postgresql://localhost /cs687 USER jcc0034 USING "f16687"; 
	
	if(argc != 7)
        {
                goto cl_exit;
        }
	
	for(i=1; i < 7; i++)
	{
		if(strcmp("-pno",argv[i]) == 0){
			pnum=atoi(argv[++i]);
		}
		 if(strcmp("-ssn",argv[i]) == 0){
			ssn=atol(argv[++i]);
                }
		 if(strcmp("-hours",argv[i]) == 0){
               		sscanf(argv[++i],"%f",&hours);	
		} 
	}
	// Requirement 1: list the employee’s name, employee’s department name, salary, and the number of dependents. 
	EXEC SQL DECLARE c_first CURSOR FOR
		SELECT e.Fname,e.Minit,e.Lname, de.Dname, e.Salary, COUNT(depe.essn) as NoOfDep FROM akashjeevan.EMPLOYEE e, akashjeevan.DEPARTMENT de, akashjeevan.DEPENDENT depe WHERE e.Ssn=:ssn AND de.dnumber=e.dno AND depe.essn=e.ssn group by depe.essn,e.Fname,e.Minit,e.Lname,de.Dname,e.Salary;


	EXEC SQL OPEN c_first;

	EXEC SQL WHENEVER NOT FOUND DO BREAK;

	while (SQLCODE==0)
	{
		EXEC SQL FETCH IN c_first INTO :fname,:minit,:lname,:dname,:salary, :depno;
		flag=1;
	}
	// Handle case if there exists no dependents
	if(flag == 0)
	{
		EXEC SQL DECLARE c_first1 CURSOR FOR
			SELECT e.Fname,e.Minit,e.Lname, de.Dname, e.Salary  FROM akashjeevan.EMPLOYEE e, akashjeevan.DEPARTMENT de WHERE e.Ssn=:ssn AND de.dnumber=e.dno;
		EXEC SQL OPEN c_first1;	
		EXEC SQL WHENEVER NOT FOUND DO BREAK;	
		while (SQLCODE==0){
			EXEC SQL FETCH IN c_first1 INTO :fname,:minit,:lname,:dname,:salary;
		}
	}
	flag=0;

	printf("___________________________________\n");
	printf("Name: %s %s %s\nDepartment name: %s\nSalary: %f \nNo. of Dependents: %d \n",fname, minit, lname, dname, salary, depno);

	// Second requirement: 
	// list of <the project number, the project name, the name of the department manager controlling the project, the number of hours the employee is working on the project, the 	number of employees working on the project, the total number of hours for the project (by all employees)>.
	EXEC SQL DECLARE c_sec_query CURSOR FOR
		SELECT p.Pnumber,p.Pname,d.Mgr_ssn,w.Hours FROM akashjeevan.EMPLOYEE e, akashjeevan.DEPARTMENT d, akashjeevan.PROJECT p, akashjeevan.WORKS_ON w  WHERE e.Ssn=:ssn AND e.Ssn=w.Essn AND p.Pnumber=w.Pno AND d.Dnumber=p.Dnum;


	EXEC SQL OPEN c_sec_query;

	EXEC SQL WHENEVER NOT FOUND DO BREAK;

	printf("___________________________________\n");
	while (SQLCODE==0)
	{
		EXEC SQL FETCH IN c_sec_query INTO :pnumber,:pname,:mgrssn,:hours1;
		
		EXEC SQL DECLARE c_sec_query_2 CURSOR FOR
			SELECT e.Fname,e.Minit,e.Lname FROM akashjeevan.EMPLOYEE e, akashjeevan.DEPARTMENT d  WHERE e.Ssn=:mgrssn AND d.Dnumber=e.Dno;	
		EXEC SQL OPEN c_sec_query_2;
		EXEC SQL FETCH IN c_sec_query_2 INTO :fname1,:minit1,:lname1;
		EXEC SQL CLOSE c_sec_query_2;	
	
		EXEC SQL DECLARE c_sec_query_3 CURSOR FOR
			SELECT count(w.ESSN), sum(w.Hours) FROM akashjeevan.WORKS_ON w  WHERE w.Pno=:pnumber;	
		EXEC SQL OPEN c_sec_query_3;
        EXEC SQL FETCH IN c_sec_query_3 INTO :count_emp,:count_hours;
		EXEC SQL CLOSE c_sec_query_3;	
	
		printf("Pnumber: %d\nPname: %s\nMgr: %s %s %s\nHours: %f\nThe number of employees working on the project: %d\nThe total number of hours for the project: %f\n", pnumber,pname,fname1,minit1,lname1, hours1, count_emp, count_hours);
		printf("___________________________________\n");
	}

	EXEC SQL CLOSE c_sec_query;



	

	//To get the pname and store it in the variable
	EXEC SQL DECLARE c_sec CURSOR FOR
		SELECT p.pname FROM akashjeevan.PROJECT p  WHERE p.Pnumber=:pnum ;
	EXEC SQL OPEN c_sec;
	EXEC SQL WHENEVER NOT FOUND DO BREAK;

	while (SQLCODE==0)
	{
		EXEC SQL FETCH IN c_sec INTO :pname;
	}
	EXEC SQL CLOSE c_sec;

	// Third requirement:
	EXEC SQL DECLARE c_second CURSOR FOR
		SELECT e.Fname,e.Minit,e.Lname, p.Pnumber,p.pname,w.Hours FROM akashjeevan.EMPLOYEE e, akashjeevan.PROJECT p, akashjeevan.WORKS_ON w  WHERE e.Ssn=:ssn AND w.Pno=:pnum AND e.Ssn=w.Essn AND p.Pnumber=w.Pno;
	EXEC SQL OPEN c_second;
	EXEC SQL WHENEVER NOT FOUND DO BREAK;

	while (SQLCODE==0)
	{
		EXEC SQL FETCH IN c_second INTO :fname,:minit,:lname,:pnum,:pname,:hours1;
		// If the employee is already working on that project, the number of hours will be updated. If flag = 1, update
		flag = 1;
	}
	// If the number of hours is set to 0, it means the corresponding tuple should be deleted if it already exists (e.g.,  “Employee ‘John B Smith’ who was working on 5 hours on project ‘ProductZ’ stopped working on this project.”).
	if(hours == 0 && flag ==1)
	{
		while (delete == 0)
		{
			EXEC SQL DELETE FROM akashjeevan.WORKS_ON W WHERE w.Essn=:ssn AND w.Pno=:pnum;
			printf("Employee \'%s %s %s\' who was working on %f hours on project \'%s\' stopped working on this project\n",fname,minit,lname,hours1,pname);	
			delete=1; 
		}
	}
	//Record does not exist
	else if(hours == 0 && flag ==0)
	{
		printf("Record not found to delete\n");
	}
	//insert message should be printed (e.g., “Employee ‘John B Smith’ started to work on 5 hours on project ‘ProductZ’.”). 
	else if(flag == 0)
	{
		while (insert == 0)
        {
			set_flag:
	
			EXEC SQL INSERT INTO akashjeevan.WORKS_ON VALUES (:ssn, :pnum, :hours);
			insert=1;
			printf("Employee \'%s %s %s\' started to work on %f hours on project \'%s\'\n",fname,minit,lname,hours,pname);	
		}
	}
	//If the hours are updated, your program should print an update message (e.g., “The number of hours for employee ‘John B Smith’ on project ‘ProductX’ is updated from 32.5 to 30.”)
	else
	{
		while (update == 0)
		{	
			EXEC SQL UPDATE akashjeevan.WORKS_ON SET Hours=:hours WHERE Essn=:ssn AND Pno=:pnum;
			printf("The number of the hours for the \'%s %s %s\' on project \'%s\' is updated from %f to %f\n", fname,minit,lname,pname,hours1,hours); 
			update=1;
		}
	}


	EXEC SQL CLOSE c_second;

	EXEC SQL COMMIT;

	EXEC SQL DISCONNECT;

	if(argc != 7)
	{
		cl_exit:
			printf("Usage: ./Filename -ssn <SSN> -pno <pno> -hours <hours>\n");
	}
	return 0;

}
