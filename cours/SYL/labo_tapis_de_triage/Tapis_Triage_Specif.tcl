#!/sw/bin/wish
# ------------------------------------------------------------------------------
#
# Nom          : Tapis_de_triage.tcl
#
# Fonction     :
#
# Auteur       : Sébastien Masle
# Date         : 14 Mai 2008
#
# Version      : 1.0
#
# Modification :
#--| Modifications |------------------------------------------------------------
# Version   Auteur Date               Description
# 1.0       BNZ    10/01/12            Adapt to the USB2 console and use the new
#                                       Graphical_Elements.tcl library. Sorry,
#                                       not a whole rewrite, just a small
#                                       adaptation.
# 1.1       FCC    04.11.2015          Compatible with Linux
# 1.2       FCC    04.01.2016          Remove driver call (not used for specif)
#-------------------------------------------------------------------------------


set Version 1.0

set Env linux

font create fnt3 -family {MS Sans Serif} -weight bold -size 8
font create fnt4 -family {MS Sans Serif} -weight bold -size 10

## distance de déplacement des vérins
set l_depl_v1 60
set l_depl_v2 60

#--| Declaration des variables globales |---------------------------------------
# valeur qui s'incrémente à chaque nouvelle boite
# permet d'avoir une gestion facile des boites
set num_boites 0
# mémorisation des boites en face des vérins
set boite1 ""
set boite2 ""
# listes des boites présentes sur chaque tapis
set boite_tapis1 ""
set list_tapis2 {}
# nombre d'itérations nécessaires pour faire un tour de moteur
# (1/3 de la largeur d'une boite)
set nbr_tour_t2 0
#--| variables d'état des capteurs |--
set Capt_Lg 0
#capteurs de présence d'une boite en face d'un vérin
set Capt_pres_tapis1 0
set Capt_pres_v1 0
set Capt_pres_v2 0
# capteur de présence d'une boite en bout de tapis
set Capt_pres_t2_out 0
# capteurs sur le moteur du tapis 2
set Capt_tapis2 1
# capteurs de position sortie des vérins
set Capt_v1_out 0
set Capt_v2_out 0
# capteurs de position rentrée des vérins
set Capt_v1_in 1
set Capt_v2_in 1
# lancement de la simulation
set run_sim 0
# boite défectueuse
set defect 0

### variable pour la simulation tcl seul (sans ModelSim)
set boite_tapis2 0
set sortir_v2 0
set rentrer_v2 0
set sortir_v1 0
set Mesure_Lg 0
set Valide_Lg 0
set Capt_Lg_old 0
set defect_save 0
set defect_auto 0
set code 00

# Load resources
set redsToolsPath /opt/tools_reds

if { [catch {source $redsToolsPath/TCL_TK/Graphical_Elements.tcl} msg1] } {
  puts "Set path for Windows environment"
  set redsToolsPath c:/EDA/tools_reds
  set Env windows
  if { [catch {source $redsToolsPath/TCL_TK/Graphical_Elements.tcl} msg2] } {   
    puts "Cannot load Graphical Elements!"
    }
}

# --| SETVARIABLES |----------------------------------------------------------------------
# --  Set fonts and addresses
# ----------------------------------------------------------------------------------------
proc SetVariables {} {
  # Global variables, see below
  global dataPin adrConfPin adrDataPin \
         adrVersion adrSUBD25OE adrReset

  # Redirect StdOut to nowhere (prevent polution in logs)
  StdOut off

  # Addresses to configuration pins of the SUB25s of the board
  set adrConfPin(D01_08) [format %d 0x4000]; # Right connector, pins 1  to 8
  set adrConfPin(D09_16) [format %d 0x4001]; # Right connector, pins 9  to 16
  set adrConfPin(D17_24) [format %d 0x4002]; # Right connector, pins 17 to 24
  set adrConfPin(D25_27) [format %d 0x4003]; # Right connector, pins 25 to 27
  set adrConfPin(G01_08) [format %d 0x4004]; # Left connector,  pins 1  to 8
  set adrConfPin(G09_16) [format %d 0x4005]; # Left connector,  pins 9  to 16
  set adrConfPin(G17_24) [format %d 0x4006]; # Left connector,  pins 17 to 24
  set adrConfPin(G25_27) [format %d 0x4007]; # Left connector,  pins 25 to 27

  # Addresses to set the value of pins of the SUB25s of the board
  set adrDataPin(D01_08) [format %d 0x5000]; # Right connector, pins 1  to 8
  set adrDataPin(D09_16) [format %d 0x5001]; # Right connector, pins 9  to 16
  set adrDataPin(D17_24) [format %d 0x5002]; # Right connector, pins 17 to 24
  set adrDataPin(D25_27) [format %d 0x5003]; # Right connector, pins 25 to 27
  set adrDataPin(G01_08) [format %d 0x5004]; # Left connector,  pins 1  to 8
  set adrDataPin(G09_16) [format %d 0x5005]; # Left connector,  pins 9  to 16
  set adrDataPin(G17_24) [format %d 0x5006]; # Left connector,  pins 17 to 24
  set adrDataPin(G25_27) [format %d 0x5007]; # Left connector,  pins 25 to 27

  # Address for the version of the FPGA
  set adrVersion [format %d 0x6000]

  # Address to reset the IOs of the board
  set adrReset [format %d 0x4fff]

  # Address to activate the IOs of the SUBD25 pins
  set adrSUBD25OE [format %d 0x4ffe]

  # Data variables for inputs/outputs
  set dataPin(D01_08) 0; # Val_A
  set dataPin(D09_16) 0; # Val_B
  set dataPin(D17_24) 0; # Switches
  set dataPin(D25_27) 0; # N/A
  set dataPin(G01_08) 0; # Result_A
  set dataPin(G09_16) 0; # Result_B
  set dataPin(G17_24) 0; # Leds
  set dataPin(G25_27) 0; # N/A

  # Reactivate StdOut
  StdOut on
}




# --| CHECKRUNNINGMODE |-------------------------------------------------------------------------
# --  Check if the console was started from simulation (Simulation running mode) or
# --  in standalone (Target running mode).
# ----------------------------------------------------------------------------------------
proc CheckRunningMode {} {
  # Global variables:
  #   - Path to the resources
  #   - Current running mode
  global Mode redsToolsPath Env

  # Directory where the USB2 drivers are installed
  set InstallDir "$redsToolsPath/lib/usb2/"
  if {$Env == "linux" } {
    set libName "libredsusb.so"
  } else {
    set libName "GestionUSB2.dll"
  }

  # No error by default
  set isErr 0

  # Check the running mode -> Simulation or Target
  catch {restart -f} err1
  if {$err1 != "invalid command name \"restart\""} {
    set Mode "Simulation"
  } else {
    set Mode "Target"
    # Test if the DLL "GestionUSB2" is installed
    # catch {load $InstallDir$libName} err2
    # if {$err2 != "" } {
    #   # Error --> try in local folder
    #   catch {load $libName} err3
    #   if {$err3 != "" } {
    #     # Installation error
    #     set msgErr "$libName n'est pas installee : $err2 - $err3"
    #     set isErr  1
    #   } else {
    #     set InstallDir .
    #   }
    # }
    # if {$isErr == 0} {
    #   UsbSetDevice 08ee 4002
    # }
  }

  # affichage de l'erreur s'il a lieu
  if {$isErr == 1} {
      tk_messageBox -icon error -type ok -title error -message $msgErr
      exit  ; # quitte l'application
  }

}
  

#--| Maj_Stimuli |--------------------------------------------------------------
# Lis la valeur des capteurs et actionne les tapis et vérins en mode Target
#-------------------------------------------------------------------------------
proc Maj_Stimuli {} {
    global Capt_pres_t2_out Capt_tapis2 Capt_pres_tapis1 defect boite_tapis2 \
    Capt_pres_v1 Capt_pres_v2 Capt_v2_in Capt_v2_out Capt_Lg Capt_Lg_old run_sim \
    Mesure_Lg sortir_v2 rentrer_v2 sortir_v1 Capt_v1_in defect_save defect_auto code

    if {$run_sim == 1} {
        setLed .top.ledtapis2 0 OFF

        if {($Capt_pres_tapis1 == 0 && $boite_tapis2 == 0) || ($Capt_pres_tapis1 == 0 && $boite_tapis2 == 1)} {
            mov_tapis1 0
            setLed .top.ledtapis1 0 ON
        } elseif {$Capt_pres_tapis1 == 1 && $boite_tapis2 == 0 && $Capt_v1_in == 1 && $Capt_v2_in == 1} {
            mov_tapis1 0
            setLed .top.ledtapis1 0 ON
            mov_tapis2 0
            setLed .top.ledtapis2 0 ON
        } else {
            setLed .top.ledtapis1 0 OFF
        }

        if {$Capt_Lg_old == 0 && $Capt_Lg == 1} {
            set Mesure_Lg 0
            set Valide_Lg 0
        } elseif {$Capt_Lg_old == 1 && $Capt_Lg == 0} {
            set defect_auto 0
            set Valide_Lg 1
        } elseif {$Capt_Lg == 1} {
            set Mesure_Lg [expr $Mesure_Lg + 1]
        }

        if {$boite_tapis2 == 0} {
            set defect_save 0
            set defect_auto 1
            set Mesure_Lg 0
        }

        if {$boite_tapis2 && $defect_auto} {
            if {$defect} {
                set defect_save 1
            }
        }

        if {$defect_save == 1} {
            set code XX
        } elseif {$Mesure_Lg < 25} {
            set code 00
        } elseif {$Mesure_Lg < 38 && $Mesure_Lg > 25} {
            set code 01
        } elseif {$Mesure_Lg < 50 && $Mesure_Lg > 38} {
            set code 10
        } elseif {$Mesure_Lg > 50} {
            set code 11
        }

        if {$boite_tapis2 == 1 && $Capt_v1_in == 1 && $Capt_v2_in == 1} {
            if {$Capt_pres_v1 == 1} {
                if {$code == 01} {
                    sortir_verin1
                } else {
                    mov_tapis2 0
                    setLed .top.ledtapis2 0 ON
                }
            } elseif {$Capt_pres_v2 == 1} {
                if {$code == 10} {
                    set sortir_v2 1
                } else {
                    mov_tapis2 0
                    setLed .top.ledtapis2 0 ON
                }
            } else {
                mov_tapis2 0
                setLed .top.ledtapis2 0 ON
            }
        }

        if {$sortir_v2 == 1} {
            sortir_verin2
            if {$Capt_v2_out} {
                set sortir_v2 0
                set rentrer_v2 1
            }
        } elseif {$rentrer_v2 == 1} {
            rentrer_verin2
            if {$Capt_v2_in} {
                set rentrer_v2 0
            }
        }

        ## remise à jour des variables de sauvegarde de l'état précédent
        set Capt_Lg_old $Capt_Lg
        .top.lMesLg configure -text "$code"

        after 40 Maj_Stimuli
    }
}


#--| RunSim |-------------------------------------------------------------------
# Met à jour la variable run_sim
#-------------------------------------------------------------------------------
proc RunSim {sim} {
    global run_sim Mode

    if {$run_sim != $sim} {
        set run_sim $sim
        if {$Mode == "ModelSim"} {
            if {$sim == 1} {
                force -freeze sim:/top_sim/S3_i 0 0, 1 {50 ns} -r 100
                RunDisplay
            } else {
                abort RunDisplay
            }
        } else {
            if {$sim == 1} {
                  Maj_Stimuli
            }
        }
    }
#    force -freeze /Top_Sim/Run_i $sim
}

#--| RunDisplay |---------------------------------------------------------------
# Lis la valeur des capteurs et actionne les tapis et vérins en mode ModelSim
#-------------------------------------------------------------------------------
proc RunDisplay {} {
    global run_sim Capt_Type_boite1 Capt_Type_boite2 Capt_Type_boite3 Capt_pres_v1 \
    Capt_pres_v2 Capt_pres_tapis1 Capt_tapis2 Capt_Lg Capt_pres_t2_out defect \
    Capt_v1_out Capt_v2_out Capt_v1_in Capt_v2_in

    if {$run_sim == 1} {

        # avancement du temps
        run 100
        force -freeze /top_sim/S2_i 1

        ## affectation des valeurs des capteurs
        force -freeze /top_sim/Val_A_i(2) $Capt_pres_tapis1
        force -freeze /top_sim/Val_A_i(3) $Capt_Lg
        force -freeze /top_sim/Val_A_i(6) $Capt_pres_t2_out

        force -freeze /top_sim/Val_A_i(4) $Capt_pres_v1
        force -freeze /top_sim/Val_A_i(5) $Capt_pres_v2

        force -freeze /top_sim/Val_A_i(0) $Capt_tapis2

        force -freeze /top_sim/S1_i $Capt_v2_out
        force -freeze /top_sim/Val_A_i(7) $Capt_v1_in
        force -freeze /top_sim/S0_i $Capt_v2_in

        force -freeze /top_sim/Val_A_i(1) $defect

        # actions à faire
        if {[examine  /top_sim/L3_o] == 1} {
            mov_tapis1 0
            setLed .top.ledtapis1 0 ON
        } else {
            setLed .top.ledtapis1 0 OFF
        }
        if {[examine  /top_sim/L4_o] == 1} {
            mov_tapis2 0
            setLed .top.ledtapis2 0 ON
        } else {
            setLed .top.ledtapis2 0 OFF
        }

        if {[examine  /top_sim/L0_o] == 1} {
            sortir_verin1
        }

        if {[examine  /top_sim/L1_o] == 1 && [examine  /top_sim/L2_o] == 1} {
        } elseif {[examine  /top_sim/L1_o] == 1} {
            sortir_verin2
        }

        if {[examine  /top_sim/L1_o] == 1 && [examine  /top_sim/L2_o] == 1} {
        } elseif {[examine  top_sim/L2_o] == 1} {
            rentrer_verin2
        }
    }
    after 10 RunDisplay
}

#--| CreateMainWindow |---------------------------------------------------------
#
#   Création de la fenêtre principale
#-------------------------------------------------------------------------------
proc CreateMainWindow {} {
    global l_depl_v1 l_depl_v2 run_sim Mode code run_sim

    ### creation du toplevel avec ses dimensions ###
    toplevel .top -class toplevel
    wm geometry .top 980x450+10+10
    wm resizable .top 0 0
    wm title .top "Tapis de triage"

    # Call "exit" when Top is closed
    wm protocol .top WM_DELETE_WINDOW exit

    # Some bindings for menu accelerator
    bind .top <Control-w> {exit}
    bind .top <Control-W> {exit}
    bind .top <Control-q> {exit}
    bind .top <Control-Q> {exit}

    ###creation du canvas pour les images ###
    canvas .top.can_image -width 700 -height 70
    place .top.can_image -x 10 -y 350
    ### creation du canvas dans lequel on met le système ###
    canvas .top.can -width 980 -height 250
    place .top.can -x 0 -y 0

    ### creation des tapis ###
    .top.can create rectangle 20 100 217 160 -fill white -width 2 -tag tapis1
    label .top.can.nomtapis1 -text "Tapis 1" -fg #009900 -bg #BBBBBB -font "fnt4"
    place .top.can.nomtapis1 -x 80 -y 161
    .top.can create rectangle 220 100 850 160 -fill white -width 2 -tag tapis2
    label .top.can.nomtapis2 -text "Tapis 2" -fg #009900 -bg #BBBBBB -font "fnt4"
    place .top.can.nomtapis2 -x 310 -y 161

    ### creation des zones d'evacuation des boites ###
    .top.can create rectangle 480 162 600 230 -fill black
    .top.can create rectangle 680 162 800 230 -fill black
    .top.can create rectangle 852 98 970 162 -fill black

    ### creation des boutons d'ajout d'une boite sur le tapis ###
    button .top.boite1 -text "boite 1" -command {create_boite 1}
    place .top.boite1 -x 20 -y 374
    .top.can_image create rectangle 85 5 125 65 -fill yellow -width 0

    button .top.boite2 -text "boite 2" -command {create_boite 2}
    place .top.boite2 -x 150 -y 374
    .top.can_image create rectangle 215 5 275 65 -fill yellow -width 0

    button .top.boite3 -text "boite 3" -command {create_boite 3}
    place .top.boite3 -x 300 -y 374
    .top.can_image create rectangle 365 5 450 65 -fill yellow -width 0

    button .top.boite4 -text "boite 4" -command {create_boite 4}
    place .top.boite4 -x 475 -y 374
    .top.can_image create rectangle 540 5 655 65 -fill yellow -width 0

    ### creation des vérins ###
    .top.can create rectangle 520 15 560 85 -fill blue
    .top.can create line 540 15 540 97 -fill blue -width 10 -tag verin_v1
    .top.can create line 505 97 575 97 -fill blue -width 2 -tag verin_h1

    .top.can create rectangle 720 15 760 85 -fill blue
    .top.can create line 740 15 740 97 -fill blue -width 10 -tag verin_v2
    .top.can create line 705 97 775 97 -fill blue -width 2 -tag verin_h2

    ### creation des capteurs ###
    createLed .top.capt1 194 161 0 vertical 1 green
    label .top.lcapttapis1 -text "Capt_piece1_i"
    place .top.lcapttapis1 -x 150 -y 190
    createLed .top.capt4 830 163 0 vertical 1 green
    label .top.lcaptfintapis2 -text "Capt_fin_tapis2_i"
    place .top.lcaptfintapis2 -x 830 -y 190
    createLed .top.captLg 320 70 0 vertical 1 green
    label .top.lcaptLg -text "Capt_Lg_i"
    place .top.lcaptLg -x 330 -y 55
    label .top.lCdLg -text "Code_i ="
    place .top.lCdLg -x 350 -y 75
    label .top.lMesLg -text "$code"
    place .top.lMesLg -x 400 -y 75

    ### Défectueux ###
    createLed .top.defectS 320 280 0 vertical 1 green
    label .top.ldefect -text "Defect_i"
    place .top.ldefect -x 320 -y 310

    ### Leds des verins ###
    createLed .top.capt2 562 67 0 vertical 1 green
    label .top.lcapttapis2 -text "capt_v1_i"
    place .top.lcapttapis2 -x 562 -y 50
    createLed .top.capt3 762 67 0 vertical 1 green
    label .top.lcapttapis3 -text "capt_v2_i"
    place .top.lcapttapis3 -x 762 -y 50
    createLed .top.captv1in 490 10 0 vertical 1 green
    setLed .top.captv1in 0 ON
    label .top.lcaptv1in -text "v1_in_i"
    place .top.lcaptv1in -x 450 -y 10
    createLed .top.captv2in 690 10 0 vertical 1 green
    setLed .top.captv2in 0 ON
    label .top.lcaptv2in -text "v2_in_i"
    place .top.lcaptv2in -x 650 -y 10
    createLed .top.captv2out 690 67 0 vertical 1 green
    label .top.lcaptv2out -text "v2_out_i"
    place .top.lcaptv2out -x 655 -y 55

    ### Led de fonctionnement des tapis ###
    createLed .top.ledtapis1 880 270 0 vertical 1 blue
    label .top.ltapis1 -text "Mot_tapis1_o"
    place .top.ltapis1 -x 800 -y 278
    createLed .top.ledtapis2 880 300 0 vertical 1 blue
    label .top.ltapis2 -text "Mot_tapis2_o"
    place .top.ltapis2 -x 800 -y 308

    # createLed .top.ledtapis3 740 270 0 vertical 1 blue
    # label .top.ltapis3 -text "Sortir_v1_o"
    # place .top.ltapis3 -x 650 -y 278
    # createLed .top.ledtapis4 740 300 0 vertical 1 blue
    # label .top.ltapis4 -text "Mot_tapis2_o"
    # place .top.ltapis4 -x 650 -y 308

#--| Creation des menus |-------------------------------------------------------

    # creation du menu principal
    menu .top.menu -tearoff 0

    #creation du menu file
    set file .top.menu.file
    menu $file  -tearoff 0
    .top.menu add cascade -label "File" -menu $file -underline 0

    #$file add command -label "Version du firmware" -command LireVersion_uC
    #$file add command -label "Version du design FPGA" -command LireVersion_FPGA

    #$file add separator
    $file add command -label "Quitter" -command exit


    # ajout du menu a la fenetre principale
    .top configure -menu .top.menu

#--------------------------------------------------------------------------------

    if {$Mode == "ModelSim"} {
        ### Creation des boutons pour la simulation ###
        button .top.runsim -text "Run simulation" -command {RunSim 1} -height 2 -width 14
        place .top.runsim -x 700 -y 355

        button .top.stopsim -text "Stop simulation" -command {RunSim 0} -height 2 -width 14
        place .top.stopsim -x 700 -y 395
    } else {
        button .top.run -text "Start" -command {RunSim 1} -height 1 -width 8
        place .top.run -x 720 -y 360

        button .top.stop -text "Stop" -command {set run_sim 0} -height 1 -width 8
        place .top.stop -x 720 -y 400
    }

    #--| Creation du bouton "Quitter" |-----------------------------------------
    button .top.exit -text Quitter -command exit -font fnt3
    place .top.exit  -x 820 -y 400 -height 22 -width 70

    #--| Creation du bouton "Defectueux" |--------------------------------------
    button .top.defect -text Défectueux -command {Defect} -height 4 -width 11
    place .top.defect -x 300 -y 200
}

#--| Defect |-------------------------------------------------------------------
# procédure qui génère un signal quand le bouton "Défectueux" est activé
#-------------------------------------------------------------------------------
proc Defect {} {
    global defect
    setLed .top.defectS 0 ON
    set defect 1
    after 40 set defect 0
    after 40 setLed .top.defectS 0 OFF
}

#-------------------------------------------------------------------------------
# Création des procédures pour faire bouger les vérins
# Une procedure par vérin pour permettre de bouger plusieurs
# vérins en même temps
#-------------------------------------------------------------------------------

#--| sortir_verin1 |------------------------------------------------------------
# paramètre l_depl_v1 : longueur du déplacement à effectuer (60 pour le vérin1)
#-------------------------------------------------------------------------------
proc sortir_verin1 {} {
  global list_tapis2 boite_tapis1 l_depl_v1 Capt_v1_out Capt_v1_in boite1 index1 \
  boite_tapis2 Mode

    set x 0

    if {$l_depl_v1 == 60} {
        ## on cherche si une boite de la liste est en face du vérin
        for {set i 0} {$i < [llength $list_tapis2]} {incr i} {
          set x [lindex [.top.can coords [lindex $list_tapis2 $i]] 2]

          ## si la boite se trouve en face du vérin, on supprime la boite de la
          ## list_tapis2 et on la met dans la variable boite_att2 pour qu'elle
          ## n'avance plus si le tapis avance
          if {$x > 570 && $x < 585} {
              set index1 $i
              set boite1 [lindex $list_tapis2 $i]
              break
          }
        }
    } else {
        set x [lindex [.top.can coords $boite1] 2]
    }

    if {$l_depl_v1 > 0} {
        ## déplacement de la boite et recadrage de la boite si elle n'est
        ## pas tout à fait en face (on s'autorise une légère erreur)
        if {$x > 570 && $x < 585} {
            .top.can move $boite1 0 5
        }

        ## sortie du vérin
        .top.can move verin_h1 0 5
        .top.can move verin_v1 0 5
        set l_depl_v1 [expr $l_depl_v1 - 5]
        set Capt_v1_in 0
        setLed .top.captv1in 0 OFF

        ## rend la sortie du vérin automatique
        if {$Mode == "ModelSim"} {
            after 10 sortir_verin1
        } else {
            after 50 sortir_verin1
        }

    } else {
        if {$boite1 != ""} {
            set list_tapis2 [lreplace $list_tapis2 $index1 $index1]
            if {$x > 570 && $x < 585} {
                .top.can delete $boite1
                set boite_tapis2 0
            }
            set boite1 ""
        }
        set Capt_v1_out 1

        ## rentre le vérin dès qu'il a fini de sortir
        rentrer_verin1
    }
}

#--| rentrer_verin1 |-----------------------------------------------------------
# paramètre l_depl_v1 : longueur du déplacement à effectuer
#-------------------------------------------------------------------------------
proc rentrer_verin1 {} {
    global l_depl_v1 Capt_v1_out Capt_v1_in Mode

    if {$l_depl_v1 < 60} {
        ##rentrée du vérin
        .top.can move verin_h1 0 -5
        .top.can move verin_v1 0 -5
        set l_depl_v1 [expr $l_depl_v1 + 5]
        set Capt_v1_out 0

        ## rend la rentrée du vérin automatique
        if {$Mode == "ModelSim"} {
            after 10 rentrer_verin1
        } else {
            after 50 rentrer_verin1
        }

    } else {
        set Capt_v1_in 1
        setLed .top.captv1in 0 ON
    }
}

#--| sortir_verin2 |------------------------------------------------------------
# paramètre l_depl_v2 : longueur du déplacement à effectuer (60 pour le vérin2)
#-------------------------------------------------------------------------------
proc sortir_verin2 {} {
    global list_tapis2 l_depl_v2 Capt_v2_out Capt_v2_in boite2 index2 boite_tapis2

    set x 0

    if {$l_depl_v2 == 60} {
        ## on cherche si une boite de la liste est en face du vérin
        for {set i 0} {$i < [llength $list_tapis2]} {incr i} {
          set x [lindex [.top.can coords [lindex $list_tapis2 $i]] 2]

          ## si la boite se trouve en face du vérin, on supprime la boite de la
          ## list_tapis2 et on la met dans la variable boite_att3 pour qu'elle
          ## n'avance plus si le tapis avance
          if {$x > 770 && $x < 785} {
              set index2 $i
              set boite2 [lindex $list_tapis2 $i]
              break
          }
        }
    } else {
        set x [lindex [.top.can coords $boite2] 2]
    }

    if {$l_depl_v2 > 0} {
        ## déplacement de la boite
        if {$x > 770 && $x < 785} {
            .top.can move $boite2 0 5
        }

        ## sortie du vérin
        .top.can move verin_h2 0 5
        .top.can move verin_v2 0 5
        set l_depl_v2 [expr $l_depl_v2 - 5]
        set Capt_v2_in 0
        setLed .top.captv2in 0 OFF
    } else {
        if {$boite2 != ""} {
            set list_tapis2 [lreplace $list_tapis2 $index2 $index2]
            if {$x > 770 && $x < 785} {
                .top.can delete $boite2
                set boite_tapis2 0
            }
            set boite2 ""
        }
        set Capt_v2_out 1
        setLed .top.captv2out 0 ON
    }
}

#--| rentrer_verin2 |-----------------------------------------------------------
# paramètre l_depl_v2 : longueur du déplacement à effectuer
#-------------------------------------------------------------------------------
proc rentrer_verin2 {} {
    global l_depl_v2 Capt_v2_out Capt_v2_in

    if {$l_depl_v2 < 60} {
        .top.can move verin_h2 0 -5
        .top.can move verin_v2 0 -5
        set l_depl_v2 [expr $l_depl_v2 + 5]
        set Capt_v2_out 0
        setLed .top.captv2out 0 OFF
    } else {
        set Capt_v2_in 1
        setLed .top.captv2in 0 ON
    }
}


#-------------------------------------------------------------------------------
# Création des procédures pour faire bouger les tapis
# Une procedure par tapis pour permettre de bouger plusieurs
# tapis en même temps
#-------------------------------------------------------------------------------

#--| mov_tapis1 |---------------------------------------------------------------
# paramètre sens : sens du déplacement à effectuer
# 0 : vers la droite
# 1 : vers la gauche
# autre : repos
#-------------------------------------------------------------------------------
proc mov_tapis1 {sens} {
  global boite_tapis1

  if {$sens == 0} {
      .top.can move $boite_tapis1 2 0
  } elseif {$sens == 1} {
      .top.can move $boite_tapis1 -2 0
  } else {
      return
  }
}

#--| mov_tapis2 |---------------------------------------------------------------
# paramètre sens : sens du déplacement à effectuer
# 0 : vers la droite
# 1 : vers la gauche
# autre : repos
#-------------------------------------------------------------------------------
proc mov_tapis2 {sens} {
  global list_tapis2 nbr_tour_t2 Capt_tapis2 boite_tapis2 Mode

  if {$sens == 0} {
      for {set i 0} {$i < [llength $list_tapis2]} {incr i} {
        .top.can move [lindex $list_tapis2 $i] 2 0
      }
      if {$nbr_tour_t2 == 3} {
          set nbr_tour_t2 0
          set Capt_tapis2 0
      } elseif {$nbr_tour_t2 == 0} {
          set nbr_tour_t2 [expr $nbr_tour_t2 + 1]
          set Capt_tapis2 1
      } else {
          set nbr_tour_t2 [expr $nbr_tour_t2 + 1]
          set Capt_tapis2 0
      }
  } elseif {$sens == 1} {
      for {set i 0} {$i < [llength $list_tapis2]} {incr i} {
        .top.can move [lindex $list_tapis2 $i] -2 0
      }
      if {$nbr_tour_t2 == 0} {
          set nbr_tour_t2 3
          set Capt_tapis2 1
      } else {
          set nbr_tour_t2 [expr $nbr_tour_t2 - 1]
          set Capt_tapis2 0
      }
  }

  set x_boite [lindex [.top.can coords [lindex $list_tapis2 0]] 0]
  if {$x_boite > 850} {
      .top.can delete [lindex $list_tapis2 0]
      set boite_tapis2 0
      set list_tapis2 [lreplace $list_tapis2 0 0]
  }
}

#-------------------------------------------------------------------------------
# Création des procédures pour la gestion des capteurs
#-------------------------------------------------------------------------------
#--| Capteur_Lg |-----------------------------------------------------------
# gestion du capteur d'avancement du tapis 2
#-------------------------------------------------------------------------------
proc Capteur_Lg {} {
    global list_tapis2 Capt_Lg

    set pres_boite 0

    ## on cherche si une boite de la liste est en face du vérin
    for {set i 0} {$i < [llength $list_tapis2]} {incr i} {
      set x1 [lindex [.top.can coords [lindex $list_tapis2 $i]] 0]
      set x2 [lindex [.top.can coords [lindex $list_tapis2 $i]] 2]

      ## si la boite se trouve en face du vérin, on supprime la boite de la
      ## list_tapis2 et on la met dans la variable boite_att3 pour qu'elle
      ## n'avance plus si le tapis avance
      if {$x2 >= 330 && $x1 <= 336} {
          set pres_boite 1
      }
    }

    if {$pres_boite == 1} {
        setLed .top.captLg 0 ON
        set Capt_Lg 1
    } else {
        setLed .top.captLg 0 OFF
        set Capt_Lg 0
    }

    after 10 Capteur_Lg
}

#--| Capt_presence1 |----------------------------------------------------------
# procédure de gestion du capteur qui détecte la présence d'une boite
# en bout de tapis 1
#-------------------------------------------------------------------------------
proc Capt_presence1 {} {
    global boite_tapis1 Capt_pres_tapis1

    set x1_boite [lindex [.top.can coords $boite_tapis1] 0]
    set x2_boite [lindex [.top.can coords $boite_tapis1] 2]

    if {$x2_boite > 210 && $x1_boite < 218} {
        setLed .top.capt1 0 ON
        set Capt_pres_tapis1 1
    } else {
        setLed .top.capt1 0 OFF
        set Capt_pres_tapis1 0
    }

    after 10 Capt_presence1
}

#--| Capt_presence2 |----------------------------------------------------------
# procédure de gestion du capteur qui détecte la présence d'une boite
# en face du vérin1
#-------------------------------------------------------------------------------
proc Capt_presence2 {} {
    global list_tapis2 Capt_pres_v1

    set Capt_pres_v1 0
    setLed .top.capt2 0 OFF

    for {set i 0} {$i < [llength $list_tapis2]} {incr i} {
      set x1_boite [lindex [.top.can coords [lindex $list_tapis2 $i]] 0]
      set x2_boite [lindex [.top.can coords [lindex $list_tapis2 $i]] 2]
      set y_boite [lindex [.top.can coords [lindex $list_tapis2 $i]] 1]
      if {$x2_boite > 575 && $x1_boite < 580} {
          if {$y_boite < 140} {
              setLed .top.capt2 0 ON
              set Capt_pres_v1 1
              break
          }
      }
    }

    after 10 Capt_presence2
}


#--| Capt_presence3 |----------------------------------------------------------
# procédure de gestion du capteur qui détecte la présence d'une boite
# en face du vérin2
#-------------------------------------------------------------------------------
proc Capt_presence3 {} {
    global list_tapis2 Capt_pres_v2

    set Capt_pres_v2 0
    setLed .top.capt3 0 OFF

    for {set i 0} {$i < [llength $list_tapis2]} {incr i} {
      set x1_boite [lindex [.top.can coords [lindex $list_tapis2 $i]] 0]
      set x2_boite [lindex [.top.can coords [lindex $list_tapis2 $i]] 2]
      set y_boite [lindex [.top.can coords [lindex $list_tapis2 $i]] 1]
      if {$x2_boite > 775 && $x1_boite < 780} {
          if {$y_boite < 140} {
              setLed .top.capt3 0 ON
              set Capt_pres_v2 1
              break
          }
      }
    }

    after 10 Capt_presence3
}

#--| Capt_presence4 |----------------------------------------------------------
# procédure de gestion du capteur qui détecte la présence d'une boite
# en fin de tapis2
#-------------------------------------------------------------------------------
proc Capt_presence4 {} {
    global list_tapis2 Capt_pres_t2_out

    set Capt_pres_t2_out 0
    setLed .top.capt4 0 OFF

    for {set i 0} {$i < [llength $list_tapis2]} {incr i} {
      set x1_boite [lindex [.top.can coords [lindex $list_tapis2 $i]] 0]
      set x2_boite [lindex [.top.can coords [lindex $list_tapis2 $i]] 2]
      if {$x2_boite > 845 && $x1_boite < 850} {
          setLed .top.capt4 0 ON
          set Capt_pres_t2_out 1
          break
      }
    }

    after 10 Capt_presence4
}

#--| Gestion_boites |-----------------------------------------------------------
# procédure qui gère le passage des boites du tapis 1 au tapis 2
#-------------------------------------------------------------------------------
proc Gestion_boites {} {
    global boite_tapis1 list_tapis2 boite_tapis2

    set x_boite [lindex [.top.can coords $boite_tapis1] 0]

    if {$x_boite > 217} {
        lappend list_tapis2 $boite_tapis1
        set boite_tapis2 1
        set boite_tapis1 ""
    }

    after 10 Gestion_boites
}

#--| create_boite |-------------------------------------------------------------
# procédure pour créer une nouvelle boite sur le tapis 1
#-------------------------------------------------------------------------------
proc create_boite {type} {
    global num_boites boite_tapis1

    #set y_boite [lindex [.top.can coords boite_tapis1] 1]

    ## vérification au préalable qu'on ne va pas superposer la nouvelle boite
    ## avec une autre
    if {$boite_tapis1 == ""} {
        if {$type == 1} {
            .top.can create rectangle 20 100 60 160 -fill yellow -width 0 -tag boite$num_boites
        } elseif {$type == 2} {
            .top.can create rectangle 20 100 80 160 -fill yellow -width 0 -tag boite$num_boites
        } elseif {$type == 3} {
            .top.can create rectangle 20 100 105 160 -fill yellow -width 0 -tag boite$num_boites
        } elseif {$type == 4} {
            .top.can create rectangle 20 100 135 160 -fill yellow -width 0 -tag boite$num_boites
        }

        set boite_tapis1 boite$num_boites

        incr num_boites
    }
}

#---| Programme principal |----------------------------------------------------
CheckRunningMode

CreateMainWindow

Capteur_Lg
Capt_presence1
Capt_presence2
Capt_presence3
Capt_presence4
Gestion_boites

