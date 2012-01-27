select private.create_model(

-- Model name, schema, table

'to_do', 'public', 'todoitem',

-- Columns

E'{
  "todoitem.todoitem_id as guid",
  "todoitem.todoitem_id as number",
  "todoitem.todoitem_name as name",
  "todoitem.todoitem_description as description",
  "(select contact_info
    from xm.contact_info
    where guid = todoitem.todoitem_cntct_id) as contact",
  "todoitem.todoitem_status as to_do_status",
  "todoitem.todoitem_active as is_active",
  "todoitem.todoitem_start_date as start_date",
  "todoitem.todoitem_due_date as due_date",
  "todoitem.todoitem_assigned_date as assign_date",
  "todoitem.todoitem_completed_date as complete_date",
  "todoitem.todoitem_notes as notes",
  "todoitem.todoitem_priority_id as priority",  
  "(select user_account_info
    from xm.user_account_info
    where username = todoitem.todoitem_owner_username) as owner",
  "(select user_account_info
    from xm.user_account_info
    where username = todoitem.todoitem_username) as assigned_to",
  "(select to_do_recurrence
    from xm.to_do_recurrence
    where to_do = todoitem.todoitem_id) as recurrence",
  "array(
    select to_do_alarm 
    from xm.to_do_alarm
    where to_do = todoitem.todoitem_id) as alarms",
  "array(
    select to_do_comment
    from xm.to_do_comment
    where to_do = todoitem.todoitem_id) as comments",
  "array(
    select contact_assignment
    from xm.contact_assignment
    where source = todoitem.todoitem_id and source_type=\'TODO\') as contacts",
  "array(
    select item_assignment
    from xm.item_assignment
    where source = todoitem.todoitem_id and source_type=\'TODO\') as items",
  "array(
    select file_assignment
    from xm.file_assignment
    where source = todoitem.todoitem_id and source_type=\'TODO\') as files",
  "array(
    select image_assignment
    from xm.image_assignment
    where source = todoitem.todoitem_id and source_type=\'TODO\') as images",
  "array(
    select url_assignment
    from xm.url_assignment
    where source = todoitem.todoitem_id and source_type=\'TODO\') as urls",
  "array(
    select to_do_assignment
    from xm.to_do_assignment
    where source = todoitem.todoitem_id and source_type=\'TODO\') as to_dos"}',

-- Rules

E'{"

-- insert rule

create or replace rule \\"_CREATE\\" as on insert to xm.to_do 
  do instead

insert into todoitem (
  todoitem_id, 
  todoitem_name, 
  todoitem_description, 
  todoitem_status, 
  todoitem_active, 
  todoitem_start_date, 
  todoitem_due_date, 
  todoitem_assigned_date, 
  todoitem_completed_date, 
  todoitem_notes, 
  todoitem_priority_id, 
  todoitem_owner_username, 
  todoitem_username )
values (
  new.guid,
  new.name,
  new.description,
  new.to_do_status,
  new.is_active,
  new.start_date,
  new.due_date,
  new.assign_date,
  new.complete_date,
  new.notes,
  new.priority,
  (new.owner).username,
  (new.assigned_to).username );

","

create or replace rule \\"_CREATE_RECURRENCE\\" as on insert to xm.to_do
  where new.recurrence is null = false do instead (

insert into xm.to_do_recurrence (
  guid,
  to_do,
  period,
  frequency,
  start_date,
  end_date,
  maximum)
values (
  (new.recurrence).guid,
  new.guid,
  (new.recurrence).period,
  (new.recurrence).frequency,
  (new.recurrence).start_date,
  (new.recurrence).end_date,
  (new.recurrence).maximum );

)

","

-- update rule

create or replace rule \\"_UPDATE\\" as on update to xm.to_do
  do instead

update todoitem set
  todoitem_id = new.guid,
  todoitem_name = new.name,
  todoitem_description = new.description,
  todoitem_status = new.to_do_status,
  todoitem_active = new.is_active,
  todoitem_start_date = new.start_date,
  todoitem_due_date = new.due_date,
  todoitem_assigned_date = new.assign_date,
  todoitem_completed_date = new.complete_date,
  todoitem_notes = new.notes,
  todoitem_priority_id = new.priority,
  todoitem_owner_username = (new.owner).username,
  todoitem_username = (new.assigned_to).username
where ( todoitem_id = old.guid );

","


create or replace rule \\"_UPDATE_RECURRENCE_CREATE\\" as on update to xm.to_do
  where old.recurrence is null and new.recurrence is null = false do instead

insert into xm.to_do_recurrence (
  guid,
  to_do,
  period,
  frequency,
  start_date,
  end_date,
  maximum)
values (
  (new.recurrence).guid,
  new.guid,
  (new.recurrence).period,
  (new.recurrence).frequency,
  (new.recurrence).start_date,
  (new.recurrence).end_date,
  (new.recurrence).maximum );

","

create or replace rule \\"_UPDATE_RECURRENCE_UPDATE\\" as on update to xm.to_do
  where old.recurrence != new.recurrence do instead (

update xm.to_do_recurrence set
  period = (new.recurrence).period,
  frequency = (new.recurrence).frequency,
  start_date = (new.recurrence).start_date,
  end_date = (new.recurrence).end_date,
  maximum = (new.recurrence).maximum
where (guid = (old.recurrence).guid );

)

","

create or replace rule \\"_UPDATE_RECURRENCE_DELETE\\" as on update to xm.to_do
  where old.recurrence is not null != new.recurrence is null do instead (

delete from xm.to_do_recurrence
where (guid = (old.recurrence).guid );

)

","

-- delete rules

create or replace rule \\"_DELETE\\" as on delete to xm.to_do 
  do instead (

delete from comment 
where ( comment_source_id = old.guid ) 
 and ( comment_source = \'TD\' );

delete from private.docinfo
where ( source_id = old.guid ) 
 and ( source_type = \'TODO\' );

delete from todoitem
where ( todoitem_id = old.guid );

)"}',

-- Conditions, Comment, System

'{}', 'ToDo Model', true, false, 'TODO');