$ moria :== "$disk$userdisk1:[mas0.masmoria.moria.execute]moria2"
$ commandline = f$trnlnm ("MAS$DRVCOM")
$ define /nolog sys$input tt
$define /nolog/user sys$command tt
$ moria 'commandline
$exit
