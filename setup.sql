------------------* * * DATA CREATION * * *------------------ 



drop table enrollments;
drop table prereq;
drop table waitlist;
drop table schclasses;
drop table courses;
drop table students;
drop table majors;

create table MAJORS
	(major varchar2(3) Primary key,
	mdesc varchar2(30));
insert into majors values ('ACC','Accounting');
insert into majors values ('FIN','Finance');
insert into majors values ('IS','Information Systems');
insert into majors values ('MKT','Marketing');

create table STUDENTS 
	(snum varchar2(3) primary key,
	sname varchar2(10),
	standing number(1),
	major varchar2(3) constraint fk_students_major references majors(major),
	gpa number(2,1),
	major_gpa number(2,1));

insert into students values ('101','Andy',4,'IS',2.8,3.2);
insert into students values ('102','Betty',2,null,3.2,null);
insert into students values ('103','Cindy',3,'IS',2.5,3.5);
insert into students values ('104','David',2,'FIN',3.3,3.0);
insert into students values ('105','Ellen',1,null,2.8,null);
insert into students values ('106','Frank',3,'MKT',3.1,2.9);
insert into students values ('107','George',3,'IS',1.8,null);
insert into students values ('108','Harry',4,'IS',3.0,3.2);

create table COURSES
	(dept varchar2(3) constraint fk_courses_dept references majors(major),
	cnum varchar2(3),
	ctitle varchar2(30),
	crhr number(3),
	standing number(1),
	primary key (dept,cnum));

insert into courses values ('IS','233','MS Office',3,1);
insert into courses values ('IS','300','Intro to MIS',3,2);
insert into courses values ('IS','301','Business Communicatons',3,2);
insert into courses values ('IS','310','Statistics',3,2);
insert into courses values ('IS','355','Networks',3,3);
insert into courses values ('IS','380','Database',3,3);
insert into courses values ('IS','385','Systems',3,3);
insert into courses values ('IS','480','Adv Database',3,4);

create table SCHCLASSES (
	callnum number(5) primary key,
	year number(4),
	semester varchar2(3),
	dept varchar2(3),
	cnum varchar2(3),
	section number(2),
	capacity number(3));

alter table schclasses 
	add constraint fk_schclasses_dept_cnum foreign key 
	(dept, cnum) references courses (dept,cnum);

--Spring
insert into schclasses values (10100,2009,'Sp','IS','233',1,3);
insert into schclasses values (10101,2009,'Sp','IS','233',2,3);
insert into schclasses values (10110,2009,'Sp','IS','300',1,3);
insert into schclasses values (10111,2009,'Sp','IS','300',2,3);
insert into schclasses values (10120,2009,'Sp','IS','301',1,3);
insert into schclasses values (10121,2009,'Sp','IS','301',2,3);
insert into schclasses values (10130,2009,'Sp','IS','355',1,3);
insert into schclasses values (10131,2009,'Sp','IS','355',2,3);
insert into schclasses values (10140,2009,'Sp','IS','380',1,3);
insert into schclasses values (10141,2009,'Sp','IS','380',2,3);
insert into schclasses values (10150,2009,'Sp','IS','385',1,3);
insert into schclasses values (10151,2009,'Sp','IS','385',2,3);
insert into schclasses values (10160,2009,'Sp','IS','480',1,3);
insert into schclasses values (10161,2009,'Sp','IS','480',2,3);

--Fall
insert into schclasses values (20100,2009,'Fa','IS','233',1,3);
insert into schclasses values (20101,2009,'Fa','IS','233',2,3);
insert into schclasses values (20110,2009,'Fa','IS','300',1,3);
insert into schclasses values (20111,2009,'Fa','IS','300',2,3);
insert into schclasses values (20120,2009,'Fa','IS','301',1,3);
insert into schclasses values (20121,2009,'Fa','IS','301',2,3);
insert into schclasses values (20130,2009,'Fa','IS','355',1,3);
insert into schclasses values (20131,2009,'Fa','IS','355',2,3);
insert into schclasses values (20140,2009,'Fa','IS','380',1,3);
insert into schclasses values (20141,2009,'Fa','IS','380',2,3);
insert into schclasses values (20150,2009,'Fa','IS','385',1,3);
insert into schclasses values (20151,2009,'Fa','IS','385',2,3);
insert into schclasses values (20160,2009,'Fa','IS','480',1,3);
insert into schclasses values (20161,2009,'Fa','IS','480',2,3);

create table PREREQ
	(dept varchar2(3),
	cnum varchar2(3),
	pdept varchar2(3),
	pcnum varchar2(3),
	primary key (dept, cnum, pdept, pcnum));
alter table Prereq 
	add constraint fk_prereq_dept_cnum foreign key 
	(dept, cnum) references courses (dept,cnum);
alter table Prereq 
	add constraint fk_prereq_pdept_pcnum foreign key 
	(pdept, pcnum) references courses (dept,cnum);

insert into prereq values ('IS','380','IS','300');
insert into prereq values ('IS','380','IS','301');
insert into prereq values ('IS','380','IS','310');
insert into prereq values ('IS','385','IS','310');
insert into prereq values ('IS','355','IS','300');
insert into prereq values ('IS','480','IS','380');

create table ENROLLMENTS (
	snum varchar2(3) constraint fk_enrollments_snum references students(snum),
	callnum number(5) constraint fk_enrollments_callnum references schclasses(callnum),
	grade varchar2(2),
	primary key (snum, callnum));
  
insert into enrollments values (101,10100,'A');
insert into enrollments values (102,10101,'A');
insert into enrollments values (103,10100,'B');
insert into enrollments values (104,10100,'F');
insert into enrollments values (105,10101,'W');


create table WAITLIST (
  snum varchar2(3) constraint fk_waitlist_snum references students(snum),
  callnum number(5) constraint fk_waitlist_callnum references schclasses(callnum),
  requesttime varchar2(100), 
  primary key (snum, callnum));
   
  
  
------------------* * * MAIN PROGRAM * * *------------------  



set serveroutput on
 
create or replace package Enroll is

procedure AddMe(
  p_snum in enrollments.snum%type,
  p_callnum in enrollments.callnum%type,
  p_ErrorMsg out varchar2);
  
procedure DropMe(
  p_snum waitlist.snum%type,
  p_callnum waitlist.callnum%type);
  
end Enroll;  
/

create or replace package body Enroll is
 
procedure AddMe(
  p_snum in enrollments.snum%type,
  p_callnum in enrollments.callnum%type,
  p_ErrorMsg out varchar2) as
  v_count_snum number;
  v_count_callnum number;
  v_count_callnum_error varchar2(1000);
  v_section_dept varchar2(1000);
  v_section_cnum varchar2(1000);
  v_count_section number;
  v_count_section_error varchar2(1000);
  v_count_credit number;
  v_count_credit_error varchar2(1000);
  v_count_standing number;
  v_count_standing_error varchar2(1000);
  v_disq_gpa number;
  v_disq_standing number;
  v_disq_error varchar2(1000);
  v_capacity number; 
  v_enrolled number;

begin
 
  select count(*) into v_count_snum  --1) Checks for valid student number
  from students 
  where snum = p_snum;
  
  if v_count_snum != 0 then

    select count(*) into v_count_callnum  --2) Checks for duplicate enrollment in same section
    from enrollments e 
    where e.snum = p_snum
    and e.callnum = p_callnum;

    if v_count_callnum = 0 then
      v_count_callnum_error := null;
    else
      v_count_callnum_error := 'You cannot enroll in the same course twice.';
    end if;
      
    select dept, cnum into v_section_dept, v_section_cnum --3) Checks for duplicate enrollment within different sections
    from schclasses
    where callnum = p_callnum;
 
    select count(*) into v_count_section
    from enrollments e inner join schclasses sc
    on e.callnum = sc.callnum
    where dept = v_section_dept
    and cnum = v_section_cnum
    and e.snum = p_snum
    and e.callnum != p_callnum
    and grade not in ('F','W');
    
    if v_count_section = 0 then
      v_count_section_error := null;
    else
      v_count_section_error := 'You cannot enroll in a different section of the same class.';
    end if;

    select count(snum) into v_count_credit --4) Checks if student will exceed 15 credit hours
    from enrollments
    where snum = p_snum;
        
    if v_count_credit * 3 <= 12 then
      v_count_credit_error := null;
    else
      v_count_credit_error := 'Adding this class will exceed the 15 unit cap.';
    end if;
      
    select count(snum) into v_count_standing --5) Checks if the student has high enough standing to enroll
    from courses c, schclasses sc, students s
    where s.standing >= c.standing
    and sc.cnum = c.cnum
    and s.snum = p_snum
    and sc.callnum = p_callnum;
      
    if v_count_standing !=0 then
      v_count_standing_error := null;
    else 
      v_count_standing_error := 'Class standing too low to enroll.';
    end if;
    
    select gpa, standing --6) Checks to see if the student has high enough GPA to enroll
    into v_disq_gpa, v_disq_standing 
    from students
    where snum = p_snum;
            
    if v_disq_gpa >= 2.0 or v_disq_standing = 1  then
      v_disq_error := null;
    else
      v_disq_error := 'Your GPA is under 2.0. You are disqualified from adding any courses.';
    end if;
    
    p_ErrorMsg := v_count_callnum_error || 
    v_count_section_error || 
    v_count_credit_error || 
    v_count_standing_error ||
    v_disq_error;
    
    if p_ErrorMsg is null then

      select capacity into v_capacity --7) Checks to see if the class has enough capacity for another student
      from schclasses 
      where callnum = p_callnum;
              
      select count(callnum) into v_enrolled
      from enrollments
      where callnum = p_callnum
      and grade is null;
              
      if v_capacity > v_enrolled then
          
        insert into enrollments values (p_snum, p_callnum, null); --9) Enrolls student to class
        commit;
        p_ErrorMsg := null; 
        dbms_output.put_line('Student ' ||p_snum|| ' has been enrolled in class ' ||p_callnum|| '.');
          
      else
      
        insert into waitlist values (p_snum, p_callnum, to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS')); --8) enrolls student to wait list
        commit;
        p_ErrorMsg := 'Sorry, this class is full. You will be placed on the waiting list for this class.';
        
      end if;  
    end if;
  else
    p_ErrorMsg := 'Invalid student number. Please check your student number and try again.'; 
  end if;
end;

procedure DropMe(
  p_snum waitlist.snum%type,
  p_callnum waitlist.callnum%type) as
  v_count_snum_callnum number;
  v_count_grade number;
  v_output varchar2(1000);

begin
  
  select count(*) into v_count_snum_callnum  --1) Checks for valid student number and callnum
  from enrollments 
  where snum = p_snum
  and callnum = p_callnum;
  
  if v_count_snum_callnum !=0 then
  
    select count(*) into v_count_grade --2) Stops student from dropping a class that they have already received a grade in
    from enrollments
    where snum = p_snum
    and callnum = p_callnum
    and grade is null;
    
    if v_count_grade != 0 then
      
      update enrollments set grade = 'W' --3) Marks dropped student with a W
      where snum = p_snum
      and callnum = p_callnum;
      commit;
      dbms_output.put_line('Student ' ||p_snum|| ' has been successfully dropped from class ' ||p_callnum|| '.');
      
      for eachrecord in  --4) Checks who is on waitlist and enrolls them into the available class.
      
      (select snum
      from waitlist
      where callnum = p_callnum
      order by requesttime) loop
        
        Enroll.AddMe(eachrecord.snum,p_callnum,v_output);
        if v_output is null then
          delete from waitlist where snum in eachrecord.snum and callnum = p_callnum;
          exit;
        end if;
     
      end loop;
      
    else
      dbms_output.put_line('You cannot drop a class that you have received a grade in or have already dropped.');
    end if;
  else
    dbms_output.put_line('Snum or CallNum not found. Please check your Snum or CallNum and try again.');
  end if;
end;

end Enroll;
/


/*-----------Execution--------------

--Add Me
declare
  v_out varchar2(1000);
begin
  Enroll.AddMe('103',20100,v_out);
  dbms_output.put_line(v_out);
end;
/

--DropMe
exec Enroll.DropMe('101', 20100); 

----------------------------------*/

  

