$!
$! MORIA backup utility program. For help on how to use, type @BACKUP ? from
$!       the DCL prompt.
$!       by Nick B Triantos
$!
$ Setup:
$       on warning then continue
$       on error then goto error_trap
$!
$ Build_paths:
$       cur_path 	:= 'f$directory()'
$       path_dist       := 'cur_path'
$       cur_len 	 = 'f$length(cur_path)' - 1
$       cur_path 	:= 'f$extract(0,cur_len,cur_path)'
$       path_source     := 'cur_path'.source]
$       path_include    := 'cur_path'.source.include]
$       path_macro      := 'cur_path'.source.macro]
$       path_execute    := 'cur_path'.execute]
$       path_backup     := "DISK$USERDISK1:[MAS0.MASMORIA.BACKUPS]"
$!
$ define_logicals:
$       define/nolog mor_main 	 	'path_dist'
$       define/nolog mor_source 	'path_source'
$       define/nolog mor_include        'path_include'
$       define/nolog mor_macro  	'path_macro'
$       define/nolog mor_execute        'path_execute'
$       define/nolog mor_backup         'path_backup'
$!
$ START:
$       mor_blank_flag :== "0"
$       if p1.eqs."?"           then goto HELP
$       write sys$output "Now backing up the specified MORIA files..."
$       if p1.eqs."LIBRARY"     then goto BACKUP_HLB
$       if p1.eqs."PASCAL"	then goto BACKUP_PASCAL
$       if p1.eqs."MACROS"	then goto BACKUP_MACROS
$       if p1.eqs."DATA"	then goto BACKUP_DATA
$       if p1.eqs."RUNFILE"	then goto BACKUP_EXE
$       if p1.nes.""		then goto BAD_PARAM
$       mor_blank_flag :== "1"
$       goto BACKUP_HLB
$!
$ BAD_PARAM:
$       write sys$output "Unrecognized parameter : ",p1
$       write sys$output "Backup ABORTED."
$       exit
$!
$ HELP:
$       type sys$input

BACKUP.COM :    Accepts one optional parameter.  By default, all steps are
                executed.  If a parameter is used, only certain steps are
                executed.
 
        Parameters:     P1
                        ?       - display this help
                                - backup all source, data, and MORIA.EXE
                        PASCAL  - backup the Pascal source files
                        MACROS  - backup the MACRO source files
                        DATA    - backup the .DAT files used at runtime
                        LIBRARY - backup the on-line MORIA Help library
                        RUNFILE - backup the executable file
 
$       exit
$!
$ BACKUP_HLB:
$       set def mor_execute
$       copy MORIAHLP.HLB mor_backup:MORIAHLP.HLB
$       purge mor_backup:MORIAHLP.HLB
$       rename mor_backup:MORIAHLP.HLB mor_backup:MORIAHLP.HLB
$       write sys$output "MORIA Help library backed up."
$       if mor_blank_flag.nes."1" then goto BYE_BYE
$!
$ BACKUP_PASCAL:
$       set def mor_source
$       copy MORIA.PAS mor_backup:MORIA.PAS
$       purge mor_backup:MORIA.PAS
$       rename mor_backup:MORIA.PAS mor_backup:MORIA.PAS
$       set def mor_include
$       copy *.INC mor_backup:*.INC
$       purge mor_backup:*.inc
$       rename mor_backup:*.INC mor_backup:*.INC
$       write sys$output "Pascal source files backed up."
$       if mor_blank_flag.nes."1" then goto BYE_BYE
$!
$ BACKUP_MACROS:
$       set def mor_macro
$       copy BOMB.C mor_backup:BOMB.C
$       purge mor_backup:BOMB.C
$       rename mor_backup:BOMB.C mor_backup:BOMB.C
$       copy *.MAR mor_backup:*.MAR
$       purge mor_backup:*.MAR
$       rename mor_backup:*.MAR mor_backup:*.MAR
$       write sys$output "MACRO source files backed up."
$       if mor_blank_flag.nes."1" then goto BYE_BYE
$!
$ BACKUP_DATA:
$       set def mor_execute
$       copy *.DAT mor_backup:*.DAT
$       purge mor_backup:*.DAT
$       rename mor_backup:*.DAT mor_backup:*.DAT
$       write sys$output "Runtime data files backed up."
$       if mor_blank_flag.nes."1" then goto BYE_BYE
$!
$ BACKUP_EXE:
$       set def mor_execute
$       copy MORIA2.EXE mor_backup:MORIA2.EXE
$       purge mor_backup:MORIA2.EXE
$       rename mor_backup:MORIA2.EXE mor_backup:MORIA2.EXE
$       write sys$output "The Moria Executable file is now backed up."
$!
$ BYE_BYE:
$       set def mor_main
$       exit
$!
$ ERROR_TRAP:
$       write sys$output "***Error resulted in termination***"
$       set def mor_main
$ exit
