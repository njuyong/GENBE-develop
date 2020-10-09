#!/usr/bin/perl
#
# Configuration script for WRF prototype code
# 
# Be sure to run as ./configure (to avoid getting a system configure command by mistake)
#

$sw_perl_path = perl ;
$sw_netcdf_path = "" ;
$sw_pnetcdf_path = "" ;
$sw_phdf5_path=""; 
$sw_jasperlib_path=""; 
$sw_jasperinc_path=""; 
$sw_esmflib_path="";
$sw_esmfinc_path="";
$sw_ldflags=""; 
$sw_compileflags=""; 
$sw_opt_level=""; 
$sw_rwordsize="\$\(NATIVE_RWORDSIZE\)";
$WRFCHEM = 0 ;
$sw_os = "ARCH" ;           # ARCH will match any
$sw_mach = "ARCH" ;         # ARCH will match any
$sw_dmparallel = "" ;
$sw_ompparallel = "" ;
$sw_stubmpi = "" ;
$sw_usenetcdff = "" ;    # for 3.6.2 and greater, the fortran bindings might be in a separate lib file
$sw_time = "" ;          # name of a timer to time fortran compiles, e.g. timex or time
$sw_ifort_r8 = 0 ;

while ( substr( $ARGV[0], 0, 1 ) eq "-" )
 {
  if ( substr( $ARGV[0], 1, 5 ) eq "perl=" )
  {
    $sw_perl_path = substr( $ARGV[0], 6 ) ;
  }
  if ( substr( $ARGV[0], 1, 7 ) eq "netcdf=" )
  {
    $sw_netcdf_path = substr( $ARGV[0], 8 ) ;
  }
  if ( substr( $ARGV[0], 1, 8 ) eq "pnetcdf=" )
  {
    $sw_pnetcdf_path = substr( $ARGV[0], 9 ) ;
  }
  if ( substr( $ARGV[0], 1, 6 ) eq "phdf5=" )
  {
    $sw_phdf5_path = substr( $ARGV[0], 7 ) ;
  }
  if ( substr( $ARGV[0], 1, 3 ) eq "os=" )
  {
    $sw_os = substr( $ARGV[0], 4 ) ;
  }
  if ( substr( $ARGV[0], 1, 5 ) eq "mach=" )
  {
    $sw_mach = substr( $ARGV[0], 6 ) ;
  }
  if ( substr( $ARGV[0], 1, 10 ) eq "opt_level=" )
  {
    $sw_opt_level = substr( $ARGV[0], 11 ) ;
  }
  if ( substr( $ARGV[0], 1, 11 ) eq "USENETCDFF=" )
  {
    $sw_usenetcdff = substr( $ARGV[0], 12 ) ;
  }
  if ( substr( $ARGV[0], 1, 5 ) eq "time=" )
  {
    $sw_time = substr( $ARGV[0], 6 ) ;
  }
  if ( substr( $ARGV[0], 1, 8 ) eq "ldflags=" )
  {
    $sw_ldflags = substr( $ARGV[0], 9 ) ;
# multiple options separated by spaces are passed in from sh script
# separated by ! instead. Replace with spaces here.
    $sw_ldflags =~ s/!/ /g ;
  }
  if ( substr( $ARGV[0], 1, 13 ) eq "compileflags=" )
  {
    $sw_compileflags = substr( $ARGV[0], 14 ) ;
    $sw_compileflags =~ s/!/ /g ;
#   look for each known option
    $where_index = index ( $sw_compileflags , "-DWRF_CHEM" ) ;
    if ( $where_index eq -1 ) 
    {
      $WRFCHEM = 0 ;
    }
    else
    {
      $WRFCHEM = 1 ;
    } 
  }
  if ( substr( $ARGV[0], 1, 11 ) eq "dmparallel=" )
  {
    $sw_dmparallel=substr( $ARGV[0], 12 ) ;
  }
  if ( substr( $ARGV[0], 1, 12 ) eq "ompparallel=" )
  {
    $sw_ompparallel=substr( $ARGV[0], 13 ) ;
  }
  shift @ARGV ;
 }

 $sw_fc = "\$(SFC)" ;
 $sw_cc = "\$(SCC)" ;
 $sw_comms_lib = "" ;
 $sw_comms_include = "" ;
 $sw_dmparallelflag = "" ;
 $sw_comms_external = "gen_comms_serial module_dm_serial" ;


 if ( $sw_dmparallel eq "RSL_LITE" ) 
 {
  $sw_fc = "\$(DM_FC)" ;
  $sw_cc = "\$(DM_CC)" ;
  $sw_dmparallelflag = "-DDM_PARALLEL" ;
  $sw_comms_lib = "\$(GEN_BE_SRC_ROOT_DIR)/external/RSL_LITE/librsl_lite.a" ;
  $sw_comms_external = "\$(GEN_BE_SRC_ROOT_DIR)/external/RSL_LITE/librsl_lite.a gen_comms_rsllite module_dm_rsllite" ;
  $sw_comms_include = "-I\$(GEN_BE_SRC_ROOT_DIR)/external/RSL_LITE" ;
 }

# The jasper library is required to build Grib2 I/O.  User must set 
# environment variables JASPERLIB and JASPERINC to paths to library and 
# include files to enable this feature prior to running configure.  
 if ( $ENV{JASPERLIB} && $ENV{JASPERINC} )
   {
   printf "Configuring to use jasper library to build Grib2 I/O...\n" ;
   printf("  \$JASPERLIB = %s\n",$ENV{JASPERLIB});
   printf("  \$JASPERINC = %s\n",$ENV{JASPERINC});
   $sw_jasperlib_path = $ENV{JASPERLIB}; 
   $sw_jasperinc_path = $ENV{JASPERINC}; 
   }
 else
   {
   printf "\$JASPERLIB or \$JASPERINC not found in environment, configuring to build without grib2 I/O...\n" ;
   }

# A separately-installed ESMF library is required to build the ESMF 
# implementation of WRF IOAPI in external/io_esmf.  This is needed 
# to couple WRF with other ESMF components.  User must set environment 
# variables ESMFLIB and ESMFINC to paths ESMF to library and include 
# files to enable this feature prior to running configure.
 if ( $ENV{ESMFLIB} && $ENV{ESMFINC} )
   {
   printf "Configuring to use ESMF library to build WRF...\n" ;
   printf "WARNING-WARNING-WARNING-WARNING-WARNING-WARNING-WARNING-WARNING\n" ;
   printf "WARNING:  THIS IS AN EXPERIMENTAL CONFIGURATION\n" ;
   printf "WARNING:  IT DOES NOT WORK WITH NESTING\n" ;
   printf "WARNING-WARNING-WARNING-WARNING-WARNING-WARNING-WARNING-WARNING\n" ;
   printf("  \$ESMFLIB = %s\n",$ENV{ESMFLIB});
   printf("  \$ESMFINC = %s\n",$ENV{ESMFINC});
   $sw_esmflib_path = $ENV{ESMFLIB};
   $sw_esmfinc_path = $ENV{ESMFINC};
   $sw_esmf_ldflag = "yes" ;
   }

# parse the configure.gen_be file

$validresponse = 0 ;

@platforms = qw ( serial smpar ) ;

# Display the choices to the user and get selection
until ( $validresponse ) {
  printf "------------------------------------------------------------------------\n" ;
  printf "Please select from among the following $sw_os $sw_mach options:\n\n" ;

  $opt = 1 ;
  open CONFIGURE_DEFAULTS, "< ./arch/configure_new.defaults" 
      or die "Cannot open ./arch/configure_new.defaults for reading" ;
  while ( <CONFIGURE_DEFAULTS> ) {

     $currline = $_;
     chomp $currline;
     # Look for our platform in the configuration option header.
     # If we're going to list it, print parallelism options
     if ( substr( $currline, 0, 5 ) eq "#ARCH" && ( index( $currline, $sw_os ) >= 0 )
         && ( index( $currline, $sw_mach ) >= 0 ) ) {
        $optstr = substr($currline,6) ;

        foreach ( @platforms ) { # Check which parallelism options are valid for this configuration option
           $paropt = $_ ;
           if ( index($optstr, $paropt) >= 0 ) { #If parallelism option is valid, print and assign number
              printf "%3d. (%s) ",$opt,$paropt ;
              $pararray[$opt] = $paropt ;
              $opttemp = $optstr ;
              $opttemp =~ s/#.*$//g ;
              chomp($opttemp) ;
              $optarray[$opt] = $opttemp." (".$paropt.")" ;
              $opt++ ;
           } else { #If parallelism option is not valid, print spaces for formatting/readability
              $paropt =~ s/./ /g ;
              printf "      %s  ",$paropt ;
           }
         }
        next;
     }

     next unless ( length $optstr ) ; # Don't read option lines unless it's valid for our platform

     if ( substr( $currline, 0, 11 ) eq "DESCRIPTION" ) {
        $optstr = $currline ; #Initial value of $optstr is DESCRIPTION line
        next;
     }

     if ( substr( $currline, 0, 3 ) eq "SFC" ) {
        $currline =~ s/^SFC\s*=\s*//g;      #remove "SFC ="
        $currline =~ s/ (\-\S*)*$//g;       #remove trailing arguments and/or spaces
        $optstr =~ s/\$SFC/$currline/g;     #Substitute the fortran compiler name into optstr
        $optstr =~ s/DESCRIPTION\s*=\s*//g; #Remove "DESCRIPTION ="
        next;
     }

     if ( substr( $currline, 0, 3 ) eq "SCC" ) {
        $currline =~ s/^SCC\s*=\s*//g;      #remove "SCC ="
        $currline =~ s/ (\-\S*)*$//g;       #remove trailing arguments and/or spaces
        $optstr =~ s/\$SCC/$currline/g;     #Substitute the C compiler name into optstr
        next;
     }

     if ( substr( $currline, 0, 4 ) eq "####" ) { #reached the end of this option's entry
        chomp($optstr) ;
        printf "  %s\n",$optstr ;
        $optstr = "";
        next;
     }

   }
  close CONFIGURE_DEFAULTS ;

  $opt -- ;

  printf "\nEnter selection [%d-%d] : ",1,$opt ;
  $response = <STDIN> ;

  if ( $response == -1 ) { exit ; }

  if ( $response >= 1 && $response <= $opt ) 
  { $validresponse = 1 ; }
  else
  { printf("\nInvalid response (%d)\n",$response);}
}
printf "------------------------------------------------------------------------\n" ;

$optchoice = $response ;

open CONFIGURE_DEFAULTS, "cat ./arch/configure_new.defaults |"  ;
$latchon = 0 ;
while ( <CONFIGURE_DEFAULTS> )
{
  if ( substr( $_, 0, 5 ) eq "#ARCH" && $latchon == 1 )
  {
    close CONFIGURE_DEFAULTS ;
    if ( $sw_opt_level eq "-f" ) {
      open CONFIGURE_DEFAULTS, "cat ./arch/postamble_new ./arch/noopt_exceptions_f |"  or die "horribly" ;
    } else {
      open CONFIGURE_DEFAULTS, "cat ./arch/postamble_new ./arch/noopt_exceptions |"  or die "horribly" ;
    }
  }
  if ( $latchon == 1 )
  {
    $_ =~ s/CONFIGURE_PERL_PATH/$sw_perl_path/g ;
    $_ =~ s/CONFIGURE_NETCDF_PATH/$sw_netcdf_path/g ;
    $_ =~ s/CONFIGURE_PNETCDF_PATH/$sw_pnetcdf_path/g ;
    $_ =~ s/CONFIGURE_PHDF5_PATH/$sw_phdf5_path/g ;
    $_ =~ s/CONFIGURE_LDFLAGS/$sw_ldflags/g ;
    $_ =~ s/CONFIGURE_COMPILEFLAGS/$sw_compileflags/g ;
    $_ =~ s/CONFIGURE_RWORDSIZE/$sw_rwordsize/g ;
    $_ =~ s/CONFIGURE_FC/$sw_time $sw_fc/g ;
    $_ =~ s/CONFIGURE_CC/$sw_cc/g ;
    $_ =~ s/CONFIGURE_COMMS_LIB/$sw_comms_lib/g ;
    $_ =~ s/CONFIGURE_COMMS_INCLUDE/$sw_comms_include/g ;
    $_ =~ s/CONFIGURE_COMMS_EXTERNAL/$sw_comms_external/g ;
    if ( $sw_os ne "CYGWIN_NT" ) {
      $_ =~ s/#NOWIN// ;
    }
    $_ =~ s/CONFIGURE_DMPARALLEL/$sw_dmparallelflag/g ;
    $_ =~ s/CONFIGURE_STUBMPI/$sw_stubmpi/g ;
    if ( $sw_ifort_r8 ) {
      $_ =~ s/^PROMOTION.*=/PROMOTION       =       -r8 /g ;
    }
    if ( $sw_dmparallel ne "" && ($_ =~ /^DMPARALLEL[=\t ]/) ) {
       $_ =~ s/#// ;
    }
    if ( $sw_ompparallel ne "" && ( $_ =~ /^OMPCPP[=\t ]/ || $_ =~ /^OMPCC[=\t ]/ || $_ =~ /^OMP[=\t ]/ ) ) {
       $_ =~ s/#// ;
       $_ =~ s/#// ;
       $_ =~ s/#// ;
    }
    if ( $sw_netcdf_path ) 
      { $_ =~ s/CONFIGURE_WRFIO_NF/wrfio_nf/g ;
	$_ =~ s:CONFIGURE_NETCDF_FLAG:-DNETCDF: ;
        if ( $sw_os == Interix ) {
	  $_ =~ s:CONFIGURE_NETCDF_LIB_PATH:\$\(GEN_BE_SRC_ROOT_DIR\)/external/io_netcdf/libwrfio_nf.a -L$sw_netcdf_path/lib $sw_usenetcdff -lnetcdf : ;
        } else {
	  $_ =~ s:CONFIGURE_NETCDF_LIB_PATH:-L\$\(GEN_BE_SRC_ROOT_DIR\)/external/io_netcdf -lwrfio_nf -L$sw_netcdf_path/lib $sw_usenetcdff -lnetcdf : ;
        }
	 }
    else                   
      { $_ =~ s/CONFIGURE_WRFIO_NF//g ;
	$_ =~ s:CONFIGURE_NETCDF_FLAG::g ;
	$_ =~ s:CONFIGURE_NETCDF_LIB_PATH::g ;
	 }

    if ( $sw_pnetcdf_path ) 
      { $_ =~ s/CONFIGURE_WRFIO_PNF/wrfio_pnf/g ;
	$_ =~ s:CONFIGURE_PNETCDF_FLAG:-DPNETCDF: ;
        if ( $sw_os == Interix ) {
	  $_ =~ s:CONFIGURE_PNETCDF_LIB_PATH:\$\(GEN_BE_SRC_ROOT_DIR\)/external/io_pnetcdf/libwrfio_pnf.a -L$sw_pnetcdf_path/lib -lpnetcdf: ;
        } else {
	  $_ =~ s:CONFIGURE_PNETCDF_LIB_PATH:-L\$\(GEN_BE_SRC_ROOT_DIR\)/external/io_pnetcdf -lwrfio_pnf -L$sw_pnetcdf_path/lib -lpnetcdf: ;
        }
	 }
    else                   
      { $_ =~ s/CONFIGURE_WRFIO_PNF//g ;
	$_ =~ s:CONFIGURE_PNETCDF_FLAG::g ;
	$_ =~ s:CONFIGURE_PNETCDF_LIB_PATH::g ;
	 }

    if ( $sw_phdf5_path ) 

      { $_ =~ s/CONFIGURE_WRFIO_PHDF5/wrfio_phdf5/g ;
	$_ =~ s:CONFIGURE_PHDF5_FLAG:-DPHDF5: ;
	$_ =~ s:CONFIGURE_PHDF5_LIB_PATH:-L\$\(GEN_BE_SRC_ROOT_DIR\)/external/io_phdf5 -lwrfio_phdf5 -L$sw_phdf5_path/lib -lhdf5_fortran -lhdf5 -lm -lz -L$sw_phdf5_path/lib -lsz: ;
	 }
    else                   
      { $_ =~ s/CONFIGURE_WRFIO_PHDF5//g ;
	$_ =~ s:CONFIGURE_PHDF5_FLAG::g ;
	$_ =~ s:CONFIGURE_PHDF5_LIB_PATH::g ;
	 }

    if ( $sw_jasperlib_path && $sw_jasperinc_path ) 
      { $_ =~ s/CONFIGURE_WRFIO_GRIB2/wrfio_grib2/g ;
        $_ =~ s:CONFIGURE_GRIB2_FLAG:-DGRIB2:g ;
        $_ =~ s:CONFIGURE_GRIB2_INC:-I$sw_jasperinc_path:g ;
        $_ =~ s:CONFIGURE_GRIB2_LIB:-L$sw_jasperlib_path -ljasper:g ;
      }
    else                   
      { $_ =~ s/CONFIGURE_WRFIO_GRIB2//g ;
        $_ =~ s:CONFIGURE_GRIB2_FLAG::g ;
        $_ =~ s:CONFIGURE_GRIB2_INC::g ;
        $_ =~ s:CONFIGURE_GRIB2_LIB::g ;
      }


    # ESMF substitutions in configure.defaults
    if ( $sw_esmflib_path && $sw_esmfinc_path )
      {
      $_ =~ s:CONFIGURE_ESMF_FLAG:-DESMFIO:g ;
      $_ =~ s:ESMFIOLIB:-L$sw_esmflib_path -lesmf -L\$\(GEN_BE_SRC_ROOT_DIR\)/external/io_esmf -lwrfio_esmf \$\(ESMF_LIB_FLAGS\):g ;
      $_ =~ s:ESMFIOEXTLIB:-L$sw_esmflib_path -lesmf -L\$\(GEN_BE_SRC_ROOT_DIR\)/external/io_esmf -lwrfio_esmf \$\(ESMF_LIB_FLAGS\):g ;
      $_ =~ s:ESMFLIBFLAG:\$\(ESMF_LDFLAG\):g ;
      }
    else
      {
        $_ =~ s:CONFIGURE_ESMF_FLAG::g ;
        $_ =~ s:ESMFLIBFLAG::g ;
        if ( $sw_os == Interix ) {
           $_ =~ s:ESMFIOLIB:\$\(GEN_BE_SRC_ROOT_DIR\)/external/esmf_time_f90/libesmf_time.a:g ;
           $_ =~ s:ESMFIOEXTLIB:-L\$\(GEN_BE_SRC_ROOT_DIR\)/external/esmf_time_f90/libesmf_time.a:g ;
        } else {
           $_ =~ s:ESMFIOLIB:-L\$\(GEN_BE_SRC_ROOT_DIR\)/external/esmf_time_f90 -lesmf_time:g ;
           $_ =~ s:ESMFIOEXTLIB:-L\$\(GEN_BE_SRC_ROOT_DIR\)/external/esmf_time_f90 -lesmf_time:g ;
        }
      }

    if ( ! (substr( $_, 0, 5 ) eq "#ARCH") ) { @machopts = ( @machopts, $_ ) ; }
    if ( substr( $_, 0, 10 ) eq "ENVCOMPDEF" )
    {
      @machopts = ( @machopts, "WRF_CHEM\t=\t$WRFCHEM \n" ) ;
    }
  }

# nesting support
# 0 = no nesting (only selectable for serial and smpar)
# 1 = basic nesting (serial and smpar compile with RSL_LITE and STUBMPI; dmpar and dm+sm use RSL_LITE and MPI)
# 2 = nesting with prescribed moves  (add -DMOVE_NESTS to ARCHFLAGS)
# 3 = nesting with prescribed moves  (add -DMOVE_NESTS and -DVORTEX_CENTER to ARCHFLAGS)

  for $paropt ( @platforms )
  {
    if ( substr( $_, 0, 5 ) eq "#ARCH" && $latchon == 0
          && ( index( $_, $sw_os ) >= 0 ) && ( index( $_, $sw_mach ) >= 0 )
          && ( index($_, $paropt) >= 0 ) )
    {
      # We are cycling through the configure_new.defaults file again.
      # This bit tries to match the line corresponding to the option we previously selected.
      $x=substr($_,6) ;
      $x =~ s/#.*$//g ;
      chomp($x) ;
      $x = $x." (".$paropt.")" ;
      if ( $x eq $optarray[$optchoice] )
      {
        $latchon = 1 ;
        $sw_ompparallel = "" ;
        $sw_dmparallel = "" ;
        $validresponse = 0 ;
        #only allow parallel netcdf if the user has chosen parallel option
        if ( $paropt ne 'dmpar' && $paropt ne 'dm+sm' ) { $sw_pnetcdf_path = "" ; }
        #
        $response = "" ;
        if ( $response == "" ) {
          if ( ( $paropt eq 'serial' || $paropt eq 'smpar' ) ) { $response = 0 ; }
          else                                                 { $response = 1 ; }
        }
        if ( $response == 0 ) {
          if ( ! ( $paropt eq 'serial' || $paropt eq 'smpar' ) ) { $response = 1 ; }
        }
        if ( ( $response == 1 ) || ( $response == 2 ) || ( $response == 3 ) ) {
          if ( ( $paropt eq 'serial' || $paropt eq 'smpar' ) ) {   # nesting without MPI
            $sw_stubmpi = "-DSTUBMPI" ;
            if ( $sw_os ne "CYGWIN_NT" ) {
              $sw_comms_lib = "\$(GEN_BE_SRC_ROOT_DIR)/external/RSL_LITE/librsl_lite.a" ;
            } else {
              $sw_comms_lib = "../external/RSL_LITE/librsl_lite.a" ;
            }
            $sw_comms_external = "\$(GEN_BE_SRC_ROOT_DIR)/external/RSL_LITE/librsl_lite.a gen_comms_rsllite module_dm_rsllite" ;
            $sw_dmparallel = "RSL_LITE" ;
            $sw_dmparallelflag = "-DDM_PARALLEL" ;
          }
        }
        if ( $paropt eq 'smpar' || $paropt eq 'dm+sm' ) { $sw_ompparallel = "OMP" ; }
        if ( $paropt eq 'dmpar' || $paropt eq 'dm+sm' ) {
          if ( $sw_os ne "CYGWIN_NT" ) {
            $sw_comms_lib = "\$(GEN_BE_SRC_ROOT_DIR)/external/RSL_LITE/librsl_lite.a" ;
          } else {
            $sw_comms_lib = "../external/RSL_LITE/librsl_lite.a" ;
          }
          $sw_comms_external = "\$(GEN_BE_SRC_ROOT_DIR)/external/RSL_LITE/librsl_lite.a gen_comms_rsllite module_dm_rsllite" ;
          $sw_dmparallel = "RSL_LITE" ;
          $sw_dmparallelflag = "-DDM_PARALLEL" ;
          $sw_fc = "\$(DM_FC)" ;
          $sw_cc = "\$(DM_CC)" ;
        }  # only one option in v3.0

        $sw_ifort_r8 = 0 ;
        if ( index ( $x, "ifort" ) > -1 || index ( $x, "intel compiler" ) > -1 ) {
          if ( $sw_rwordsize == 8 ) {
            $sw_ifort_r8 = 1 ;
          }
        }
      }
    }
  }
}

if ($latchon == 0) { # Never hurts to check that we actually found the option again.
  unlink "configure.gen_be";
  print "\nERROR ERROR ERROR ERROR\n\n";
  print "SOMETHING TERRIBLE HAS HAPPENED: configure.gen_be not created correctly.\n";
  print 'Check "$x" and "$optarray[$optchoice]"';
  die   "\n\nERROR ERROR ERROR ERROR\n\n";
}

close CONFIGURE_DEFAULTS ;
close POSTAMBLE ;
close ARCH_NOOPT_EXCEPTIONS ;

open CONFIGURE_WRF, "> configure.gen_be" or die "cannot append configure.gen_be" ;
open ARCH_PREAMBLE, "< arch/preamble_new" or die "cannot open arch/preamble_new" ;
my @preamble;
# apply substitutions to the preamble...
while ( <ARCH_PREAMBLE> )
  {
  # ESMF substitutions in preamble
  if ( $sw_esmflib_path && $sw_esmfinc_path )
    {
    $_ =~ s/ESMFCOUPLING/1/g ;
    $_ =~ s:ESMFMODDEPENDENCE:\$\(GEN_BE_SRC_ROOT_DIR\)/external/io_esmf/module_utility.o:g ;
    $_ =~ s:ESMFMODINC:-I$sw_esmfinc_path -I\$\(GEN_BE_SRC_ROOT_DIR\)/main:g ;
    $_ =~ s:ESMFIOINC:-I\$\(GEN_BE_SRC_ROOT_DIR\)/external/io_esmf:g ;
    $_ =~ s:ESMFIODEFS:-DESMFIO:g ;
    $_ =~ s:ESMFTARGET:wrfio_esmf:g ;
    }
  else
    {
    $_ =~ s/ESMFCOUPLING/0/g ;
    $_ =~ s:ESMFMODDEPENDENCE:\$\(GEN_BE_SRC_ROOT_DIR\)/external/esmf_time_f90/module_utility.o:g ;
    $_ =~ s:ESMFMODINC::g ;
    $_ =~ s:ESMFIOINC:-I\$\(GEN_BE_SRC_ROOT_DIR\)/external/esmf_time_f90:g ;
    $_ =~ s:ESMFIODEFS::g ;
    $_ =~ s:ESMFTARGET:esmf_time:g ;
    }

  @preamble = ( @preamble, $_ ) ;
  }
close ARCH_PREAMBLE ;
print CONFIGURE_WRF @preamble  ;
close ARCH_PREAMBLE ;
printf CONFIGURE_WRF "# Settings for %s\n", $optarray[$optchoice] ;
print CONFIGURE_WRF @machopts  ;

close CONFIGURE_WRF ;

printf "Configuration successful. To build GEN_BE type 'compile gen_be'. \n" ;
printf "------------------------------------------------------------------------\n" ;


