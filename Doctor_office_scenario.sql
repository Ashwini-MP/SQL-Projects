/*Requirement1:
Using a procedure) The system should be able to add new offices to the system making sure it is not a duplicate and has a valid type.   
A message should be returned with the success or failure of the action. (Phone numbers may be added without the use of a stored procedure) 
*/


create or alter proc usp_insert_office
(@name varchar(20), @type varchar(20), @street varchar(20), @city varchar(20), @zipcode char(5), @state char(2))
as 
begin

--checking for duplicates

if exists (select1 from office where upper(name)=upper(@name))
begin
print 'Duplicate Record'
end

else

--validating valid office types from the look up table

if not exists (select 1 from valid_office_types where upper(type)= upper(@type))
begin
print 'invalid office type'
end

else

begin
        begin transaction

--Insert if there is no deuplicate and has a valid office type

insert into office (name, type, street, city, zipcode, state)
values(@name, @type, @street, @city, @zipcode, @state)

if @@error <>0
begin
   print 'Insert Failed'
   rollback transaction
   return
  end

else

begin

--Display success message if the action is successful

print 'Insert Successful'

commit transaction

end
end
end
*****************************************************
create table office_phone(phone_id int identity, office_id int, phone_number varchar (15))

***********************************************************************
/*Requirement 2)
(Using a procedure) The system should be able to add doctors (making sure of no duplicates) with a valid specialty and a valid office.  A message should be returned with the success or failure of the action.
*/

create table doctor(doctor_id int not null identity primary key, fname varchar(20) not null, lname varchar(20) not null unique, speciality varchar(20) not null check (speciality='pediatrician, cardiologist,internist', hired_date date not null, salary numeric(8,2) not null check(salary>=0), office_id int foreign key) 

create or alter proc usp_insert_doctor
(@fname varchar(20),@lname varchar(20), @speciality varchar(20), @hired_date datetime, @salary numeric(8,2), @office_id int)
as 
begin

--checking for duplicates

if exists (select1 from doctor where upper(lname)=upper(@lname))
begin
print 'Duplicate Record'
end

--validating valid office types from the office table

else if not exists (select 1 from office where office_id = @office_id)
begin
print 'Office doesnot exists'
end

--validating speciality from the valid_speciality table

else if not exists (select 1 from valid_speciality where upper(speciality)= @upper(speciality)
begin
print 'Invalid speciality'
end

else

begin
        begin transaction

--Insert making sure no duplicates and has a valid office and speciality type

insert into doctor (fname, lname, speciality, hired_date, salary, office_id)
values(@fname, @lname, @speciality, @hired_date, @salary, @office_id)

if @@error <>0
begin
   print 'Insert Failed'
   rollback transaction
   return
  end

else

begin

--Display success message if the action is successful

print 'Insert Successful'

commit transaction

end
end
end

execute usp_add_doctor 'Anil', 'Kumar', 'internist', '2017-10-9', '6000', 3
########################################################################################
/* Requirement 3
(Using a procedure) The system should be able to add patients (making sure of no duplicates).  A message should be returned with success or failure.
*/

create table patient
(patient_id int not null identity primary key, 
fname varchar(20) not null, 
lname varchar(20) not null unique, 
state char(2) not null, 
city varchar (20) not null, 
street varchar (20) not null, 
zipcode char (5) not null, ) 

create or alter proc usp_add_patient
(@fname varchar(20), @lname varchar(20), @state char(2), @city varchar(20), @street varchar(20), @zipcode char(5))
as 
begin

--checking for duplicates

if exists (select 1 from patient where upper(lname)=upper(@lname))
begin
print 'Duplicate Record'
end

else

begin
        begin transaction

--Insert making sure no duplicates

insert into doctor (fname, lname, state, city, street, zipcode)
values(@fname, @lname, @state, @city, @street, @zipcode)

if @@error <>0
begin
   print 'Insert Failed'
   rollback transaction
   return
  end

else

begin

--Display success message if the action is successful

print 'Insert Successful'

commit transaction

end
end
end

********************************************************
/*Requirement 4
(Using a procedure and a trigger) The system should be able to insert a patient record for each visit made.  Each time a patient visits, the balance should be updated (via trigger).  
*/

create table record
(record_id int not null identity primary key, 
foreign key (doctor_id) references doctor(doctor_id)
amount_charged numeric(5,2) not null,
primary_diagnosis varchar(20) not null,
date_of_visit datetime not null,
foreign key (patient_id) references patient(patient_id)


create or alter proc usp_add_record
(@doctor_id int, @amount_charged numeric(5,2), primary_diagnosis varchar(20), date_of_visit datetime, patient_id int)
as 
begin

--validating primary diagnosis types from the lookup table

if not exists (select 1 from valid_primary_diagnosis where upper(primary_diagnosis)=upper(@primary_diagnosis))
begin
print 'Invalid Primary diagnosis type'
end

else

begin
        begin transaction

--Insert

insert into record(doctor_id, amount_charged, primary_diagnosis, date_of_visit, patient_id)
values(@doctor_id, @amount_charged, primary_diagnosis , date_of_visit, patient_id)

if @@error <>0
begin
   print 'Insert Failed'
   rollback transaction
   return
  end

else

begin

--Display success message if the action is successful

print 'Insert Successful'

commit transaction

end
end
end
 
Trigger:
create or alter trigger add_count
on record
for insert
as begin

declare @in_patient_id int, @in_amount_charged numeric (5,2)
select @in_patient_id= (select patient_id from inserted)
select @in_amount_charged= (select amount_charged from inserted)

--Update the account balance

update patient
set account_balance = account_balance+@in_amount_charged
where patient_id=@in_patient_id

if @@error<>0
begin
rollback transaction
return
end
end

####################################################
/* requirement 5
(Using a procedure) Given a valid patient id and an address, the system should be able to update the patients address.  A message should be returned with the success or failure of the action
*/

create or alter proc usp_update_patient_address
(@patient_id int, @street varchar(20))
as
begin

---validate patient id from the patient table

if not exists (select 1 from patient where patient_id =@patient_id)
begin 
print 'cannot update the address since patient_id is not valid'
end

else

begin

begin transaction
--update the address with the new address
update patient
set street=@street
where patient_id=@patient_id

if @@error<>0
begin 
rollback transaction
return
end

else
begin
select 'Address updated successfully'
commit transaction
end
end
end

####################################################
/* requirement 6
(Using a procedure) Given a valid office type and zip code, the system should all offices in that zip code of that type.
*/

create or alter proc show_offices 
(@type varchar(20), @zipcode char(5))
as 
begin 
--validate office type from the lookup table

if not exists (select 1 from valid_office_type where upper(type)= upper(@type))
begin
print 'Office type is not valid'
end
else

if not exists (select 1 from patient where zipcode = @zipcode))
begin
print ‘invalid zip code’
end

else 

begin 
begin transaction

--
select name, zipcode from patient where upper(type)= upper(@type)

if (@@error<>0)

begin 
rollback transaction
return 
end 
else 
begin 
commit transaction
end 
end
end

******************************************************
/* Requirement 7
(Using a procedure) The system should be able to record patient payments.
*/

create table payment
(payment_id int not null primary key identity,
patient_id foreign key references patient(patient_id) not null,
amount numeric(5,2) not null,
payment_type varchar(15) not null,
payment_date datetime not null)


create or alter proc usp_record_payment
(@patient_id int, @amount numeric(5,2), @payment_type varchar(15), @payment_date datetime)
as
begin 
/*verifying valid payment types  from the lookup table*/
if not exists (select 1 from valid_payment_types where upper(payment_type) = upper(@payment_type))
begin
select ('invalid payment type')
end
else 
begin
begin transaction
/* insert payment details */
insert into payment (patient_id, amount, payment_type, payment_date)
values (@patient_id, @amount, @payment_type, @payment_date)

if @@error<>0 
begin 
rollback transaction
return
end
else 
begin
commit transaction
end
end
end
*******************************
/* requirement 8
Using a trigger, every time a payment is made, reduce that amount from the patient balance.  
*/

	create or alter trigger update_balance
	on payment
	for insert
	as 
	begin
	--decalaring two variables in_patient_id and in_amount to get the values from inserted row
	declare @in_patient_id int, @in_amount(5,2)
	select @in_patient_id = (select patient_id from inserted)
	select @in_amount = (select amount from inserted)
	update patient
	set account_balance = account_balance-@amount     
	where patient_id = @in_patient_id                             
	if @@error<>0                                             
	begin
	rollback transaction 
	return 
	end
	end









