-- IVP for Utility Per Select
-- By calling TB-Function TS is invoked indirectly

select * from table (IDUG.copytb('IDUG', 'CMD_PROT'));

select * from table (IDUG.runstatstb('IDUG', 'CMD_PROT'));

select * from table (IDUG.checktb('IDUG', 'CMD_PROT'));

select * from table (IDUG.displaytb('IDUG', 'CMD_PROT'));
select * from table (IDUG.displaytb('IDUG', 'CMD_PROT', 'ADVRES'));
select * from table (IDUG.displaytb('IDUG', 'CMD_PROT', 'LOCKS'));

select * from table (IDUG.reorgtb('IDUG', 'CMD_PROT'));

select * from table (IDUG.quiescetb('IDUG', 'CMD_PROT'));
