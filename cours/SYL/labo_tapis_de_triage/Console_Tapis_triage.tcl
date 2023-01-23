# !/sw/bin/wish
# ----------------------------------------------------------------------------------------
# -- HEIG-VD /////////////////////////////////////////////////////////////////////////////
# -- Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
# -- School of Business and Engineering in Canton de Vaud
# ----------------------------------------------------------------------------------------
# -- REDS Institute //////////////////////////////////////////////////////////////////////
# -- Reconfigurable Embedded Digital Systems
# ----------------------------------------------------------------------------------------
# --
# -- File                 : REDS_console.tcl
# -- Author               : Jean-Pierre Miceli
# -- Date                 : 7 octobre 2005
# --
# -- Context              : Laboratoires de numerique
# --
# ----------------------------------------------------------------------------------------
# -- Description :
# --   Console virtuelle similaire aux consoles physique de laboratoire.
# --   Cette console est utilisee avec QuestaSim a partir des signaux definis dans TopSim.
# --
# --   Voici la liste des elements graphiques utilisables dans la console:
# --     - Led
# --     - Switch
# --     - Afficheur 7 segments
# --     - Afficheur de niveaux
# --     - Entree de valeurs numeriques
# --     - Sortie de valeurs numeriques
# --     - Scale
# --
# --   L'utilisation des elements graphiques se fait au moyen de fonctions:
# --     - create    pour la creation
# --     - set       pour activer une valeur
# --     - read      pour la lecture de la valeur
# --
# --   Tous les elements graphiques ne sont pas utilises dans cette version.
# --
# ----------------------------------------------------------------------------------------
# -- Modifications :
# -- Ver   Date        Engineer   Comments
# -- 1.1d  See header  JP Miceli  Initial version
# --                              version totalement nouvelle utilisant les nouveaux
# --                              composants graphiques. Le but est de mettre en route la
# --                              nouvelle methodologie pour pouvoir 'facilement' creer
# --                              une nouvelle interface --> base pour la creation de la
# --                              version avec USB et ModelSim.
# --                              - N'affiche plus le numero de version dans le titre.
# --                                Probleme lorsqu'un script appel cette console.
# -- 1.2a  26.10.2010  GCD        Remise en forme des headers.
# --                              Ajout de destruction d'objet a la fermeture
# --                              permettant la reouverture et evite de charger
# --                              la memoire d'anciens objets.
# -- 1.2b  27.10.2010  GCD        Suppression des elements graphiques et ajout de la
# --                              Dependence a "Graphical_Elements.tcl" moyennant les
# --                              adaptations suivantes:
# --                              - "createSwitch" devient "createButton"
# --                              - "readSwitch" devient "readButton"
# --                              - "initSwitch" devient "initButton"
# -- 2.0   16.12.2010  GCD        Fonctions pour l'utilisation avec la console USB2
# --                              Utilise le fichier "Top_EPM.vhd" pour l'integration de
# --                              composants.
# --                              Detail des operations:
# --                              - Ajout de la fonction "CheckRunningMode"
# --                              - Ajout de la fonction "SetVariables"
# --       06.01.2011  GCD        - Ajout de la configuration des E/S et des fonctions
# --                                pour la lecture et l'ecriture des E/S.
# --                                (i) Tests possibles en connectant un connecteur
# --                                    a l'autre.
# --                              - Ajout du mode continu (activable avec checkbutton)
# --                              - Ajout d'informations pour le debug
# -- 2.1   18.01.2011  GCD        Ajout du menu d'aide:
# --                              - a propos
# --                              - Designation des signaux:
# --                                => Si l'image "REDS_console_sigImg.gif" existe, elle
# --                                   est affichee dans une nouvelles fenetre. L'image
# --                                   doit etre au format "gif" et de dimensions 479x259.
# --                                   Le fichier "REDS_console_sigImg.vsd" permet de
# --                                   creer cette image.
# -- 3.0   08.09.2014  GHR        Console modifie precedemment pour fonctionner sous linux  
# --                              avec Questasim et Logisim. Attention dans modelsim.init
# --                              la variable DefaultRadix doit valoir 2 pour binaire!
# --                              Ajoute le connecteur 80 poles en mode target.
# -- 3.1   28.11.2014  GHR        Modifier la procedure bin2dec_v2 pour qu'elle ne traite
# --                              les caracteres speciaux lors du lancement de la console
# --                              dans different environnement (Questasim, Logisim)
# -- 3.2   28.11.2014  GHR	      Nom des signaux _i et _o remplaces par _sti et _obs
# --
# -- 3.2.1 17.02.2014  GHR        Nom des signaux _sti et _obs inverses.
# -- 3.2.2 23.03.2015  KGS        Modification commentaires assignation pins ValA et ValB
# --                              (poids fort et faible étaient inversés).
# -- 3.2.3 20.04.2015  GHR        Test de redsToolsPath pour pouvoir executer la console 
# --                              depuis Linux ou Windows.
# -- 3.3   20.04.2015  GHR        Retirer les anciennes procedures dec2bin et bin2dec.
# -- 4.0   26.06.2015  YSR        Modifier les appels de logisim a la console: 
# --                              - proc enableLogisim:
# --                                  => Elle est appelee depuis logisim et sert de switch
# --                                     pour savoir si la console est utilisee avec 
# --                                     logisim.
# --                              - proc logisimForce: 
# --                                  => Appelee lorsqu'il y a un "tick" dans logisim. 
# --                                     Les sorties de la console sont recuperer dans
# --                                     logisim.
# --                              - proc logisimExamine: 
# --                                  => Lorsqu'une entree de la console change d'etat,
# --                                     logisim appelle cette procedure et la console
# --                                     lit les valeurs d'entrees.
# -- 4.0.1 26.06.2015  GHR        Retire la procedure refresh qui n'est plus utilise
# --                              par logisim et ajout de commentaires.
# --
# ----------------------------------------------------------------------------------------

package require Tk

# Set global variables
set consoleInfo(version) 4.0.1
set consoleInfo(title) "Console Tapis de triage"; # Title that will be display in title bar
set consoleInfo(filename) "Tapis_Triage"; # Filename without the filetype

set redsToolsPath /opt/tools_reds
set Env linux
set debugMode FALSE; # Display debug info
set sigImgFile "./REDS_console_sigImg.gif"

set nbrOfSwitches 4
set runText Stop
# Variables globales spécifiques au projet :


set l_depl_tapis 1


# distance de déplacement des vérins
set l_depl_v1 60
set l_depl_v2 60
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
set nbr_tour_t2 1
# --| variables d'état des capteurs |--
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
set run_sim 1
# boite défectueuse
set defect 0

set sortir_v1_old 0

set etatInit 0
set code 00
set Mesure_Lg 0


set L0 0
set L1 0
set L2 0
set L3 0
set L4 0



# Load resources
if { [catch {source $redsToolsPath/TCL_TK/Graphical_Elements.tcl} msg1] } {
  puts "Set path for Windows environment"
  set redsToolsPath c:/EDA/tools_reds
  set Env windows
  if { [catch {source $redsToolsPath/TCL_TK/Graphical_Elements.tcl} msg2] } {   
    puts "Cannot load Graphical Elements!"
    }
}

source $redsToolsPath/TCL_TK/StdProc.tcl

# ----------------------------------------------------------------------------------------
# -- Fonctions appelees par Logisim  /////////////////////////////////////////////////////
# ----------------------------------------------------------------------------------------

# --| ENABLELOGISIM |---------------------------------------------------------------------
# --   Set fonts and addresses
# ----------------------------------------------------------------------------------------
proc enableLogisim {enabled} {
  global logisimEnabled
  #TRUE or FALSE
  set logisimEnabled $enabled
  echo "Logisim enabled: $logisimEnabled"
}

# --| LOGISIMFORCE |----------------------------------------------------------------------
# --   Dans Logisim, Lorsqu'un "tick" est genere, cette fonction est appele
# ----------------------------------------------------------------------------------------
proc logisimForce {} {
  SetOutputs
}

# --| LOGISIMEXAMINE |--------------------------------------------------------------------
# --   Dans Logisim, Lorsqu'une valeur change d'etat a l'entree de la console, 
# --   cette fonction est appelee.
# ----------------------------------------------------------------------------------------
proc logisimExamine {} {
  ReadInputs
}

# ----------------------------------------------------------------------------------------
# -- Fonctions de gestion de la console //////////////////////////////////////////////////
# ----------------------------------------------------------------------------------------

# --| SETVARIABLES |----------------------------------------------------------------------
# --  Set fonts and addresses
# ----------------------------------------------------------------------------------------
proc SetVariables {} {
  # Global variables, see below
  global fnt speed runningMode \
         dataPin adrConfPin adrDataPin \
         adrVersion adrSUBD25OE adrReset \
         strResourcePath images windowOpen adr80pCONNOE logisimEnabled

  set logisimEnabled FALSE

  # Redirect StdOut to nowhere (prevent polution in logs)
  StdOut off

  # Fonts
  font create fnt{3} -family {MS Sans Serif} -weight bold -size 8; puts ""
  font create fnt{4} -family {MS Sans Serif} -weight normal -size 8; puts ""
  font create fnt{5} -family {Courier New} -weight normal -size 8; puts ""

  # Speeds
  if {$runningMode == "Simulation"} {
    set speed(Refresh) 100; # Time [ms] between run steps (target mode)
  } else {
    set speed(Refresh) 50;
  }

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
  
  # Addresses for configuration pins of the 80pCONN of the board
  set adrConfPin(80pConnPort1) [format %d 0x4008]; # 80p connector, pins 1  to 8
  set adrConfPin(80pConnPort2) [format %d 0x4009]; # 80p connector, pins 9  to 16
  set adrConfPin(80pConnPort3) [format %d 0x400a]; # 80p connector, pins 17  to 24
  set adrConfPin(80pConnPort4) [format %d 0x400b]; # 80p connector, pins 25  to 32
  set adrConfPin(80pConnPort5) [format %d 0x400c]; # 80p connector, pins 33  to 40
  set adrConfPin(80pConnPort6) [format %d 0x400d]; # 80p connector, pins 41  to 48
  set adrConfPin(80pConnPort7) [format %d 0x400e]; # 80p connector, pins 49  to 56
  set adrConfPin(80pConnPort8) [format %d 0x400f]; # 80p connector, pins 57  to 64
  set adrConfPin(80pConnPort9) [format %d 0x4010]; # 80p connector, pins 65  to 72
  set adrConfPin(80pConnPort10) [format %d 0x4011]; # 80p connector, pins 73  to 80
  
   # Addresses to set the value of pins of the 80pCONN of the board
  set adrDataPin(80pConnPort1) [format %d 0x5008]; # 80p connector, pins 1  to 8
  set adrDataPin(80pConnPort2) [format %d 0x5009]; # 80p connector, pins 9  to 16
  set adrDataPin(80pConnPort3) [format %d 0x500a]; # 80p connector, pins 17  to 24
  set adrDataPin(80pConnPort4) [format %d 0x500b]; # 80p connector, pins 25  to 32
  set adrDataPin(80pConnPort5) [format %d 0x500c]; # 80p connector, pins 33  to 40
  set adrDataPin(80pConnPort6) [format %d 0x500d]; # 80p connector, pins 41  to 48
  set adrDataPin(80pConnPort7) [format %d 0x500e]; # 80p connector, pins 49  to 56
  set adrDataPin(80pConnPort8) [format %d 0x500f]; # 80p connector, pins 57  to 64
  set adrDataPin(80pConnPort9) [format %d 0x5010]; # 80p connector, pins 65  to 72
  set adrDataPin(80pConnPort10) [format %d 0x5011]; # 80p connector, pins 73  to 80

  # Address for the version of the FPGA
  set adrVersion [format %d 0x6000]

  # Address to reset the IOs of the board
  set adrReset [format %d 0x4fff]

  # Address to activate the IOs of the SUBD25 pins
  set adrSUBD25OE [format %d 0x4ffe]
  
  # Address to activate the IOs of the 80pCONN pins
  set adr80pCONNOE [format %d 0x4ffd]

  # Data variables for inputs/outputs
  set dataPin(D01_08) 0; # Val_A
  set dataPin(D09_16) 0; # Val_B
  set dataPin(D17_24) 0; # Switches
  set dataPin(D25_27) 0; # N/A
  set dataPin(G01_08) 0; # Result_A
  set dataPin(G09_16) 0; # Result_B
  set dataPin(G17_24) 0; # Leds
  set dataPin(G25_27) 0; # N/A

  # Images
  #set images(labels) [image create photo -file "$strResourcePath/img/REDS_console_labels.gif"]; puts ""

  # To check if windows are open
  set windowOpen(SignalLabels) FALSE
  set windowOpen(About) FALSE

  # Reactivate StdOut
  StdOut on
}


# --| CLOSECONSOLE |----------------------------------------------------------------------
# --  Prepare la fermeture de la console en detruisant certains des objets crees. Ceci
# --  permet la reouverture de la console, mais evite egalement la polution de la memoire
# --  en detruisant les objets inutilises.
# --  Cette procedure est appelee a la fermeture de la fenetre ainsi que par la
# --  procedure "QuitConsole{}".
# ----------------------------------------------------------------------------------------
proc CloseConsole {} {
  global fnt runningMode adrReset adrConfPin runText

  # Stop simulation if it is running
  if {$runText == "Stop"} {
    set runText Run
  }

  # Destruction des objets du top
  foreach w [winfo children .top] {
    destroy $w
  }

  # Desctruction du top
  destroy .top

  # Suppression des polices
  font delete fnt{3}
  font delete fnt{4}

  if {$runningMode == "Simulation"} {
    # Delete all signal on wave view
    #delete wave *

  } else {
    # Reset the line driver OE of the board
    EcrireUSB $adrReset 0

    # Set all pins of both SUB25 as Inputs
    foreach element [array names adrConfPin] {
      EcrireUSB $adrConfPin($element) [format %d 0x00]
    }

    # Exit application
    exit
  }

  # Free variable
  unset runText
  unset runningMode
}


# --| QuitConsole |-----------------------------------------------------------------------
# --  Appel la fonction de fermeture de la console, puis quitte.
# ----------------------------------------------------------------------------------------
proc QuitConsole {} {
  CloseConsole; # Clean before closing
  exit
}


# --| CHECKRUNNINGMODE |-------------------------------------------------------------------------
# --  Check if the console was started from simulation (Simulation running mode) or
# --  in standalone (Target running mode).
# ----------------------------------------------------------------------------------------
proc CheckRunningMode {} {
  # Global variables:
  #   - Path to the resources
  #   - Current running mode
  global strResourcePath runningMode redsToolsPath consoleInfo Env

  # Directory where the USB2 drivers are installed
  set InstallDir "$redsToolsPath/lib/usb2/"
  if {$Env == "linux" } {
    set libName "libredsusb.so"
  } else {
    set libName "GestionUSB2.dll"
  }

  # No error by default
  set isErr 0

  # Check for standalone run (meaning it has not been launched from QuestaSim)
  if {[wm title .] == $consoleInfo(filename)} {
    wm withdraw .
  }

  # Check the running mode -> Simulation or Target
  catch {restart -f} err1
  if {$err1 != "invalid command name \"restart\""} {
    set runningMode "Simulation"
  } else {
    set runningMode "Target"
    # Test if the DLL "GestionUSB2" is installed
    catch {load $InstallDir$libName} err2
    if {$err2 != "" } {
      # Error --> try in local folder
      catch {load $libName} err3
      if {$err3 != "" } {
        # Installation error
        set msgErr "$libName n'est pas installee : $err2 - $err3"
        set isErr  1
      } else {
        set InstallDir .
      }
    }
    if {$isErr == 0} {
      UsbSetDevice 08ee 4002
    }
  }

  # affichage de l'erreur s'il a lieu
  if {$isErr == 1} {
      tk_messageBox -icon error -type ok -title error -message $msgErr
      exit  ; # quitte l'application
  }

}
  


# --| CREATEMAINWINDOW |------------------------------------------------------------------
# --  Creation de la fenetre principale comprenand:
# --    - 16 Leds
# --    - 16 Interrupteurs
# --    - 3 Affichages 7 segments
# --    - 2 Entrees numeriques
# --    - 2 Sorties numeriques ('Result')
# ----------------------------------------------------------------------------------------
proc CreateMainWindow {} {
  global consoleInfo fnt{3} runningMode images debugLabel runText code
  global continuMode sigImgFile
  global nbrOfLeds nbrOfSwitches

  # creation de la fenetre principale
  toplevel .top -class toplevel

  # Call "CloseConsole" when Top is closed
  wm protocol .top WM_DELETE_WINDOW CloseConsole

  #set Win_Width  780
  #set Win_Height 260

  # Center to screen
  #set x0 [expr {([winfo screenwidth  .top] - $Win_Width)/2 - [winfo vrootx .top]}]
  #set y0 [expr {([winfo screenheight .top] - $Win_Height)/2 - [winfo vrooty .top]}]
  # Finally... do not center
  #set x0 200
  #set y0 200

 # wm geometry .top $Win_Width\x$Win_Height+$x0+$y0
  wm geometry .top 980x450+10+10
  wm resizable  .top 0 0 
  wm title .top "$consoleInfo(title) $consoleInfo(version) - $runningMode mode"

  # Creation des 'frame' entree et sortie
  #canvas .top.main
  #place .top.main -x 0 -y 0 -height $Win_Height -width $Win_Width

 wm protocol .top WM_DELETE_WINDOW QuitConsole

    # Some bindings for menu accelerator
    bind .top <Control-w> {QuitConsole}
    bind .top <Control-W> {QuitConsole}
    bind .top <Control-q> {QuitConsole}
    bind .top <Control-Q> {QuitConsole}

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
    .top.can create rectangle 480 162 580 230 -fill black
    .top.can create rectangle 695 162 795 230 -fill black
    .top.can create rectangle 852 98 970 162 -fill black

    ### creation des boutons d'ajout d'une boite sur le tapis ###
    button .top.boite1 -text "boite 1" -command {create_boite 1}
    place .top.boite1 -x 75 -y 415
    .top.can_image create rectangle 70 5 110 65 -fill yellow -width 0

    button .top.boite2 -text "boite 2" -command {create_boite 2}
    place .top.boite2 -x 215 -y 415
    .top.can_image create rectangle 200 5 260 65 -fill yellow -width 0

    button .top.boite3 -text "boite 3" -command {create_boite 3}
    place .top.boite3 -x 377 -y 415
    .top.can_image create rectangle 350 5 435 65 -fill yellow -width 0

    button .top.boite4 -text "boite 4" -command {create_boite 4}
    place .top.boite4 -x 565 -y 415
    .top.can_image create rectangle 525 5 640 65 -fill yellow -width 0

    ### creation des vérins ###
    .top.can create rectangle 520 15 560 85 -fill blue
    .top.can create line 540 15 540 97 -fill blue -width 10 -tag verin_v1
    .top.can create line 505 97 575 97 -fill blue -width 2 -tag verin_h1

    .top.can create rectangle 720 15 760 85 -fill blue
    .top.can create line 740 15 740 97 -fill blue -width 10 -tag verin_v2
    .top.can create line 705 97 775 97 -fill blue -width 2 -tag verin_h2

    ### creation des capteurs ###
    #LED déplacée de 12 contre la gauche pour que la boite tombe dans le bac
    createLed .top.capt1 182 161 0 vertical 1 green	
    label .top.lcapttapis1 -text "Capt_piece1_i"
    place .top.lcapttapis1 -x 150 -y 190
    createLed .top.capt4 830 163 0 vertical 1 green
    label .top.lcaptfintapis2 -text "Capt_fin_tapis2_i"
    place .top.lcaptfintapis2 -x 830 -y 190
    createLed .top.captLg 320 70 0 vertical 1 green
    label .top.lcaptLg -text "Capt_Lg_i"
    place .top.lcaptLg -x 330 -y 55
    
    ### Code de Longueur ###
    label .top.lcodelg -text "Code_i ="
    place .top.lcodelg -x 350 -y 75
    label .top.lmesglg -text "$code"
    place .top.lmesglg -x 400 -y 75

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
    place .top.lcaptv2out -x 645 -y 67

    ### Led de fonctionnement des tapis ###
    createLed .top.ledtapis1 880 270 0 vertical 1 blue
    label .top.ltapis1 -text "Mot_tapis1_o"
    place .top.ltapis1 -x 800 -y 278
    createLed .top.ledtapis2 880 300 0 vertical 1 blue
    label .top.ltapis2 -text "Mot_tapis2_o"
    place .top.ltapis2 -x 800 -y 308
    
    ### Led de fonctionnement des tapis ###
    createLed .top.ledcmdv1 555 270 0 vertical 1 blue
    label .top.lcmdv1 -text "Cmd_V1_o"
    place .top.lcmdv1 -x 490 -y 278
    createLed .top.ledcmdinv2 750 270 0 vertical 1 blue
    label .top.lcmdinv2 -text "Cmd_V2_in_o"
    place .top.lcmdinv2 -x 660 -y 278
    createLed .top.ledcmdoutv2 750 300 0 vertical 1 blue
    label .top.lcmdoutv2 -text "Cmd_V2_out_o"
    place .top.lcmdoutv2 -x 660 -y 308

#--| Creation des menus |-------------------------------------------------------

    # creation du menu principal
    menu .top.menu -tearoff 0

    #creation du menu file
    set file .top.menu.file
    set run .top.menu.run
    set help .top.menu.help
    menu $file  -tearoff 0
    menu $run -tearoff 0
    menu $help -tearoff 0
    .top.menu add cascade -label "File" -menu $file -underline 0
    .top.menu add cascade -label "Run" -menu $run -underline 0
    .top.menu add cascade -label "?" -menu $help -underline 0
    $file add command -label "Quitter" -command exit

 # "Run" menu
  $run add command -label "Run" -command StartStopManager -accelerator "Ctrl-R" \
                   -underline 0
  $run add command -label "Stop" -command StartStopManager -accelerator "Ctrl-S" \
                   -underline 0 -state disabled
  $run add separator
  $run add checkbutton -label "Run continu" -variable continuMode

  # Some bindings for menu accelerator
  bind .top <Control-r> {RunStep}
  bind .top <Control-R> {RunStep}


  # "File" menu
  $file add command -label "Fermer" -command CloseConsole -accelerator "Ctrl-W" \
                    -underline 0
  $file add separator
  $file add command -label "Quitter" -command QuitConsole -accelerator "Ctrl-Q" \
                    -underline 0

    # ajout du menu a la fenetre principale
    .top configure -menu .top.menu

# --------------------------------------------------------------------------------

    ### Creation des boutons pour la simulation ###
    checkbutton .top.continuMode -text "Continu" -font fnt{3} -variable continuMode
    place .top.continuMode -x 900 -y 360
  
    # button .top.runsim -text "Run simulation" -command StartStopManager -height 2 -width 14
    button .top.run -text "Run" -command {StartStopManager} -font fnt{3} -textvariable runText
    place .top.run -x 820 -y 360 -height 22 -width 70
         
    #--| Creation du bouton "Restart" |-----------------------------------------
    button .top.restart -text Restart -command {RestartSim}
    place .top.restart  -x 820 -y 390 -height 22 -width 70

    #--| Creation du bouton "Quitter" |-----------------------------------------
    button .top.exit -text Quitter -command QuitConsole -font fnt3
    place .top.exit  -x 820 -y 420 -height 22 -width 70
    
    #--| Creation du bouton "Reset" |-----------------------------------------
    createButton .top.resetLog 900 390 0 "" vertical 1	
    label .top.resetbutton -text "Reset"
    place .top.resetbutton -x 930 -y 405
    label .top.resetlogbutton -text "Logisim"
    place .top.resetlogbutton -x 930 -y 420

    #--| Creation du bouton "Defectueux" |--------------------------------------
    button .top.defect -text Defectueux -command {Defect} -height 4 -width 11
    place .top.defect -x 300 -y 200
}


# --| ShowSignalLabels |------------------------------------------------------------------
# --  Show a side window with the image $images(sigImgLabels)"
# ----------------------------------------------------------------------------------------
proc ShowSignalLabels {} {
  global images sigImgFile windowOpen

  proc CloseSignalLabels {} {
    global windowOpen
    set windowOpen(SignalLabels) FALSE;
    wm withdraw .info;
    destroy .info
  }

  if {$windowOpen(SignalLabels) == FALSE} {
    # Create and arrange the dialog contents.
    toplevel .info

    set windowOpen(SignalLabels) TRUE
    wm protocol .info WM_DELETE_WINDOW {CloseSignalLabels}

    set screenx [winfo screenwidth .top]
    set screeny [winfo screenheight .top]
    set x [expr [winfo x .top] + [winfo width .top] + 10]
    set y [expr [winfo y .top]]
    set width 478
    set height 259

    if {[expr $x + $width] > [expr $screenx]} {
      set x [expr $x - [winfo width .top] - $width - 10]
    }

    # Canvas for the boat image
    canvas .info.cimg -height $height -width $width
    place .info.cimg -x 0 -y 0

    set images(sigImgLabels) [image create photo -file "$sigImgFile"]; puts ""
    .info.cimg create image [expr $width/2] [expr $height/2] -image $images(sigImgLabels)

    wm geometry  .info [expr $width]x[expr $height]+$x+$y
    wm resizable  .info 0 0
    wm title     .info "D\E9signation des signaux"
    wm deiconify .info
  }
}


# --| ShowAbout |-------------------------------------------------------------------------
# --  Show the "About" window
# ----------------------------------------------------------------------------------------
proc ShowAbout {} {
    global infoLabel windowOpen consoleInfo

  proc CloseAbout {} {
    global windowOpen
    set windowOpen(About) FALSE;
    wm withdraw .about;
    destroy .about

    wm attributes .top -disabled FALSE
    wm attributes .top -alpha 1.0
  }

  if {$windowOpen(About) == FALSE} {
    # Create and arrange the dialog contents.
    toplevel .about

    set windowOpen(About) TRUE
    wm protocol .about WM_DELETE_WINDOW {CloseAbout}

    # Disable top
    wm attributes .top -disabled TRUE
    wm attributes .top -alpha 0.8

    set width 250
    set height 200

    set x [expr [winfo x .top]+[winfo width .top]/2-$width/2]
    set y [expr [winfo y .top]+[winfo height .top]/2-$height/2]

    button .about.ok -text OK -command {CloseAbout}
    place .about.ok -x [expr $width/2] -y [expr $height-20] -width 70 -height 30 -anchor s

    set infoLabel "$consoleInfo(title) version $consoleInfo(version) \
                   \n\nAuteurs:\nJean-Pierre Miceli\nGilles Curchod \
                   \n\nREDS (c) 2005 - [clock format [clock seconds] -format %Y]"
    label .about.label -textvariable infoLabel -font fnt{5} -justify center
    place .about.label -x [expr $width/2] -y 20 -anchor n

    wm geometry  .about [expr $width]x[expr $height]+$x+$y
    wm title     .about "a propos"
    wm transient .about .top
    wm attributes .about -topmost; # On top fo all
    wm resizable  .about 0 0; # Cannot resize
    wm frame .about

  }
}

# --| ShowSignalList |--------------------------------------------------------------------
# --  Show a side window with the content of file "SignalList.txt"
# ----------------------------------------------------------------------------------------
proc ShowSignalList {} {
  global infoLabel

  # Create and arrange the dialog contents.
  toplevel .info

  set x [expr [winfo x .top] + [winfo width .top] + 10]
  set y [expr [winfo y .top]]

  #button .info.ok -text OK -command {wm withdraw .info;   destroy .info}
  #place .info.ok -x 275  -y 190 -width 65 -height 20
  text .info.text -yscrollcommand ".info.scroll set"
  scrollbar .info.scroll -command ".info.text yview"

  set infoLabel ""
  label .info.label -textvariable infoLabel -font fnt{5} -justify left
  place .info.label -x 5 -x 5

  set firstLine TRUE

  set fileId [open ./SignalList.txt r]
  while {![eof $fileId]} {
    set line [gets $fileId]
    if {$firstLine == TRUE} {
      set infoLabel "$line"
      set firstLine FALSE
    } else {
      set infoLabel "$infoLabel\n$line"
    }
  }

  close $fileId

  wm geometry  .info 350x287+$x+$y
  wm resizable  .info 0 0
  wm title     .info "D\E9signation des signaux"
  wm deiconify .info

}

# --| dec2bin |---------------------------------------------------------------------------
# --  Transform a decimal value to a binary string. (Max 32-bits)
# --    - value:   The value to be converted
# --    - NbrBits: Number of bit of "value"
# ----------------------------------------------------------------------------------------
proc dec2bin {value {NbrBits 16}} {
    binary scan [binary format I $value] B32 str
    return [string range $str [expr 32-$NbrBits] 31]
}

# --| bin2dec |---------------------------------------------------------------------------
# --  Tranform a binary string to an integer
# --    - NbrBits: Number of bits in the binary string
# ----------------------------------------------------------------------------------------
proc bin2dec {binString {NbrBits 16}} {
  set result 0
  set max [string length $binString]
  set min [expr $max - $NbrBits]
  for {set j $min} {$j < $max} {incr j} {
    set bit [string range $binString $j $j]
    if {$bit != "0" && $bit != "1"} {
      set bit 0
    }
    set result [expr $result << 1]
    set result [expr $result | $bit]
  }
  return $result
}

proc bin2int {binString} {

  set result 0

  set lastBit [expr [string length $binString]-1]
  #set signBit [string range $binString $lastBit $lastBit]

  set ttl "Controle des valeurs"
  set msg "$lastBit / $signBit"

  tk_messageBox -parent .top -icon warning -type ok -title $ttl -message $msg

  for {set j 0} {$j < [string length $binString]} {incr j} {
      set bit [string range $binString $j $j]
      set result [expr $result << 1]
      set result [expr $result | $bit]
  }
  return $result
}



# --| SetOutputs |------------------------------------------------------------------------
# --  Affectation des signaux
# ----------------------------------------------------------------------------------------
proc SetOutputs {} {
  global runningMode adrDataPin debugLabel debugMode nbrOfSwitches Capt_pres_t2_out Capt_pres_tapis1
  global Capt_tapis2 defect Capt_pres_v1 Capt_pres_v2 Capt_v1_in Capt_v2_in Capt_v2_out Capt_Lg
  
  # Affectation des valeurs aux signaux respectifs
  if {$runningMode == "Simulation"} {
    #for {set i 0} {$i < $nbrOfSwitches} {incr i} {
    #  force -freeze /console_sim/S$i\_sti $singleSwitchState($i)
    #}
    #force -freeze /console_sim/Val_A_sti [dec2bin $valAEntry]
    #force -freeze /console_sim/Val_B_sti [dec2bin $valBEntry]
    
    set val [expr $Capt_tapis2 | $defect << 1 | $Capt_pres_tapis1 << 2 | $Capt_Lg << 3 | $Capt_pres_v1 << 4 | $Capt_pres_v2 << 5 | $Capt_pres_t2_out << 6 | $Capt_v1_in << 7]

    force -freeze /console_sim/Val_A_sti [dec2bin $val]

    force -freeze /console_sim/S1_sti $Capt_v2_out
    force -freeze /console_sim/S0_sti $Capt_v2_in


    # TODO : Reset !!
    force -freeze /console_sim/S2_sti [expr ![readButton .top.resetLog 0]]

       
  } else {
  
    set val [expr 0 | $Capt_pres_t2_out << 1 | $Capt_pres_tapis1 << 2 | $Capt_tapis2 << 3 | $defect << 4 | $Capt_pres_v1 << 5 | $Capt_pres_v2 << 6 | $Capt_v1_in << 7]
    EcrireUSB $adrDataPin(G01_08) $val
    EcrireUSB $adrDataPin(D01_08) $val
    puts "Capt_pres_t2_out"
    puts $Capt_pres_t2_out
    puts "Capt_pres_tapis1"
    puts $Capt_pres_tapis1
    puts "Capt_mot"
   puts $Capt_tapis2
    puts "defect"
    puts $defect
     puts "Capt_pres_v1"
    puts $Capt_pres_v1
     puts "Capt_pres_v2"
    puts $Capt_pres_v2
     puts "Capt_v1_in"
    puts $Capt_v1_in
    set val [expr 0 | $Capt_v2_in << 1 | $Capt_v2_out << 2 | $Capt_Lg << 3]
    EcrireUSB $adrDataPin(G09_16) $val
    EcrireUSB $adrDataPin(D09_16) $val
     puts "Capt_v2_in"
    puts $Capt_v2_in
     puts "Capt_v2_out"
    puts $Capt_v2_out
     puts "Capt_Lg"
    puts $Capt_Lg
    puts "Write Out"
   #set valAentry_7_0  [bin2dec [string range [dec2bin $valAEntry] 8  15]]
    #set valAentry_15_8 [bin2dec [string range [dec2bin $valAEntry] 0   7]]
    #set valBentry_7_0  [bin2dec [string range [dec2bin $valBEntry] 8  15]]
    #set valBentry_15_8 [bin2dec [string range [dec2bin $valBEntry] 0   7]]
  
    #EcrireUSB $adrDataPin(80pConnPort6) $valAentry_7_0
    #EcrireUSB $adrDataPin(80pConnPort7) $valAentry_15_8
    #EcrireUSB $adrDataPin(80pConnPort8) $valBentry_7_0
    #EcrireUSB $adrDataPin(80pConnPort9) $valBentry_15_8
    # EcrireUSB $adrDataPin(D17_24) $switchesStates
  }

  if {$debugMode == TRUE} {
    set debugLabel(1) "VA:$valAEntry|VB:$valBEntry|S:$switchesStates"
  }
}


# --| ReadInputs |------------------------------------------------------------------------
# --  Lecture des entrees
# ----------------------------------------------------------------------------------------
proc ReadInputs {} {
  global runningMode adrDataPin debugLabel debugMode nbrOfLeds L0 L1 L2 L3 L4 Mesure_Lg

  # --------------------------------------------------------------------------------------
  # Lecture des valeurs des entrees
  # --------------------------------------------------------------------------------------

  if {$runningMode == "Simulation"} {
	  
    set L0 [examine /console_sim/L0_obs]
    set L1 [examine /console_sim/L1_obs]
    set L2 [examine /console_sim/L2_obs]
    set L3 [examine /console_sim/L3_obs]
    set L4 [examine /console_sim/L4_obs]
	  set Mesure_Lg [bin2dec [examine /console_sim/Result_A_obs]]
   

  } else {
    ## /!\ ECRITURE SUR CONSOLE USB2 /!\ ##
	set Value [LireUSB $adrDataPin(D17_24)]
	set Value [expr $Value / 2]
	set L3 [expr $Value % 2]
	puts "Mot tapis 1"
	puts $L3
	set Value [expr $Value / 2]
	set L4 [expr $Value % 2]
	puts "Mot tapis 2"
	puts $L4
	set Value [expr $Value / 2]
	set L2 [expr $Value % 2]
	puts "Rentrer V2"
	puts $L2
	set Value [expr $Value / 2]
	set L0 [expr $Value % 2]
	puts "Sortir V1"
	puts $L0
	set Value [expr $Value / 2]	
	set L1 [expr $Value % 2]
	puts "Sortir V2"
	puts $L1
	set Value [expr $Value / 2]	
	set Mesure_Lg [expr $Value % 4]
	puts "Mesure Lg"
	puts $Mesure_Lg
        puts "Read USB"
  }

  if {$debugMode == TRUE} {
    set debugLabel(0) "RA:$Result_A|RB:$Result_B|L:$ledsState"
  }

  # --------------------------------------------------------------------------------------
  # Mise a jour des affichages
  # --------------------------------------------------------------------------------------

}


# --| RunDisplay |------------------------------------------------------------------------
# --  Son role est determiner lorsque le bouton "Run" est presse ou en continu si
# --  la console est utilise avec Logisim, Questasim ou en standalone.
# --  La commande "run" permet de declencher un "tick" dans Logisim.
# ----------------------------------------------------------------------------------------
proc RunDisplay {} {
  global logisimEnabled L0 L1 L2 L3 L4 Mesure_Lg sortir_v1_old
   puts "RunDisplay"
  if {$logisimEnabled == TRUE} {
    echo "Console running through Logisim..."
    run
  } else {
   puts "RunQuestaDisplay"
    runQuestaTarget
  }
  
          # actions � faire
        if {$L3 == 1} {
            mov_tapis1 0
            setLed .top.ledtapis1 0 ON
        } else {
            setLed .top.ledtapis1 0 OFF
        }
        if {$L4 == 1} {
            mov_tapis2 0
            setLed .top.ledtapis2 0 ON
        } else {
            setLed .top.ledtapis2 0 OFF
        }

        if {$L0 == 1 && $sortir_v1_old == 0} {
            sortir_verin1
            set sortir_v1_old 1
        } elseif {$L0 == 0} {
            set sortir_v1_old 0
        }

        if {$L1 == 1 && $L2 == 1} {
        } elseif {$L1 == 1} {
            sortir_verin2
        }

        if {$L1 == 1 && $L2 == 1} {
        } elseif {$L2 == 1} {
            rentrer_verin2
        }     
        
         .top.lmesglg configure -text [string range [dec2bin $Mesure_Lg] 14 15]
}

# --| runQuestaTarget |-------------------------------------------------------------------
# --  Son role est de forcer les valeurs des entrees, de faire avancer le temps
# --  et enfin d'affecter les valeurs obtenues.
# --  Elle est appelee seulement si la console est utilise avec Questasim ou en
# --  standalone.
# ----------------------------------------------------------------------------------------
proc runQuestaTarget {} {
  global runningMode runText

  # Affectation des sorties
  SetOutputs
 puts "RunQuestaTarget"
  # Avancement du temps
  if {$runningMode == "Simulation"} {
    run 100 ns
  } else {
    ## Target mode...
    after 1 {
        set continue 1
    }
    vwait continue
    update
    set continue 0
  }

  # Lecture des entrees
  ReadInputs
}

proc StartStopManager {} {
  global runText continuMode

  if {$runText == "Stop"} {
    set runText Run
    .top.menu.run entryconfigure 0 -state normal
    .top.menu.run entryconfigure 1 -state disabled
  } else {
    if {$continuMode == 1} {
      set runText Stop
      .top.menu.run entryconfigure 0 -state disabled
      .top.menu.run entryconfigure 1 -state normal
      RunContinu
    } else {
    
     puts "Run display Manager"
      RunDisplay
    }
  }
}

proc RunContinu {} {
  global runText speed
     puts "Run displayContinu"
  while {$runText=="Stop"} {
    after $speed(Refresh) {
      RunDisplay
      set continue 1
    }
    vwait continue
    update
    set continue 0
  }
}


# --| RestartSim |------------------------------------------------------------------------
# --  Gestion du redemarage d'une simulation
# ----------------------------------------------------------------------------------------
proc RestartSim {} {
  global runningMode boite_tapis1 list_tapis2 l_depl_v1 l_depl_v2 etatInit boite1 boite2 nbr_tour_t2 Capt_Lg Capt_tapis2 defect  
  
      ## effacement des boites
    if {$boite_tapis1 != ""} {
        .top.can delete $boite_tapis1
    }
    if {$list_tapis2 != ""} {
        for {set i 0} {$i < [llength $list_tapis2]} {incr i} {
            .top.can delete [lindex $list_tapis2 $i]
        }
    }
    if {$l_depl_v1 != 60} {
        .top.can move verin_h1 0 [expr $l_depl_v1 - 60]
        .top.can move verin_v1 0 [expr $l_depl_v1 - 60]
        set Capt_v1_in 1
        set Capt_v1_out 0
    }
    if {$l_depl_v2 != 60 && $etatInit == 0} {
        .top.can move verin_h2 0 [expr $l_depl_v2 - 60]
        .top.can move verin_v2 0 [expr $l_depl_v2 - 60]
        set Capt_v2_in 1
        set Capt_v2_out 0
    } elseif {$l_depl_v2 != 0 && $etatInit == 1} {
        .top.can move verin_h2 0 [expr $l_depl_v2]
        .top.can move verin_v2 0 [expr $l_depl_v2]
        set Capt_v2_in 0
        set Capt_v2_out 1
    }

    ## RAZ des variables
    set l_depl_v1 60
    if {$etatInit == 0} {
        set l_depl_v2 60
    } else {
        set l_depl_v2 0
    }
    set boite1 ""
    set boite2 ""
    set boite_tapis1 ""
    set list_tapis2 {}
    set nbr_tour_t2 0
    set Capt_Lg 0
    set Capt_tapis2 1
 #   set run_sim 0
    set defect 0
    
    
  # Redemarrage de la simulation
  if {$runningMode == "Simulation"} {
    restart -f
  }
   puts "restart"

  # Lecture des entrees
  ReadInputs

  # initialisatin des variables d'entrees
  #initButton  .top.main.inputFrame.switch
  setResult .top.main.outputFrame.result A ""
  setResult .top.main.outputFrame.result B ""

  if {$runningMode == "Target"} {
    puts "Run mode Target"
    RunDisplay
  }
}



# --| Defect |-------------------------------------------------------------------
# procédure qui génère un signal quand le bouton "Défectueux" est activé
# -------------------------------------------------------------------------------
proc Defect {} {
    global defect runningMode
        puts "defect"
    setLed .top.defectS 0 ON
    set defect 1
    if {$runningMode == "Simulation"} {
        after 100 set defect 0
        after 100 setLed .top.defectS 0 OFF
    } else {
        after 40 set defect 0
        after 40 setLed .top.defectS 0 OFF
    }
}

# -------------------------------------------------------------------------------
# Création des procédures pour faire bouger les vérins
# Une procedure par vérin pour permettre de bouger plusieurs
# vérins en même temps
# -------------------------------------------------------------------------------

# --| sortir_verin1 |------------------------------------------------------------
# paramètre l_depl_v1 : longueur du déplacement à effectuer (60 pour le vérin1)
# -------------------------------------------------------------------------------
proc sortir_verin1 {} {
  global list_tapis2 boite_tapis1 l_depl_v1 Capt_v1_out Capt_v1_in boite1 index1 \
  run_sim

    set x 0

    if {$l_depl_v1 == 60} {
        ## on cherche si une boite de la liste est en face du vérin
        for {set i 0} {$i < [llength $list_tapis2]} {incr i} {
          set x [lindex [.top.can coords [lindex $list_tapis2 $i]] 2]

          ## si la boite se trouve en face du vérin, on supprime la boite de la
          ## list_tapis2 et on la met dans la variable boite_att2 pour qu'elle
          ## n'avance plus si le tapis avance
          if {$x > 560 && $x < 580} {
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
        #if {$x > 570 && $x < 585} {
            .top.can move $boite1 0 5
        #}

        ## sortie du vérin
        .top.can move verin_h1 0 5
        .top.can move verin_v1 0 5
        set l_depl_v1 [expr $l_depl_v1 - 5]
        set Capt_v1_in 0
        setLed .top.captv1in 0 OFF

        ## rend la sortie du vérin automatique
        if {$run_sim == 1} {
            after 50 sortir_verin1
        }

    } else {
        if {$boite1 != ""} {
            if {$x > 560 && $x < 585} {
                set list_tapis2 [lreplace $list_tapis2 $index1 $index1]
                .top.can delete $boite1
            }
            set boite1 ""
        }
        set Capt_v1_out 1

        ## rentre le vérin dès qu'il a fini de sortir
        rentrer_verin1
    }
}

# --| rentrer_verin1 |-----------------------------------------------------------
# paramètre l_depl_v1 : longueur du déplacement à effectuer
# -------------------------------------------------------------------------------

# GROS PROBLEME !
proc rentrer_verin1 {} {
    global l_depl_v1 Capt_v1_out Capt_v1_in run_sim

    if {$l_depl_v1 < 60} {
        ##rentrée du vérin
        .top.can move verin_h1 0 -5
        .top.can move verin_v1 0 -5
        set l_depl_v1 [expr $l_depl_v1 + 5]
        set Capt_v1_out 0

        ## rend la rentrée du vérin automatique
        if {$run_sim == 1} {
            after 50 rentrer_verin1
        }

    } else {
        set Capt_v1_in 1
        setLed .top.captv1in 0 ON
    }
}

# --| sortir_verin2 |------------------------------------------------------------
# paramètre l_depl_v2 : longueur du déplacement à effectuer (60 pour le vérin2)
# -------------------------------------------------------------------------------
proc sortir_verin2 {} {
    global list_tapis2 l_depl_v2 Capt_v2_out Capt_v2_in boite2 index2 run_sim

    set x 0

    if {$l_depl_v2 == 60} {
        ## on cherche si une boite de la liste est en face du vérin
        for {set i 0} {$i < [llength $list_tapis2]} {incr i} {
          set x [lindex [.top.can coords [lindex $list_tapis2 $i]] 2]

          ## si la boite se trouve en face du vérin, on supprime la boite de la
          ## list_tapis2 et on la met dans la variable boite_att3 pour qu'elle
          ## n'avance plus si le tapis avance
          if {$x > 770 && $x < 795} {
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
        #if {$x > 770 && $x < 785} {
            .top.can move $boite2 0 3
        #}

        ## sortie du vérin
        .top.can move verin_h2 0 3
        .top.can move verin_v2 0 3
        set l_depl_v2 [expr $l_depl_v2 - 3]
        set Capt_v2_in 0
        setLed .top.captv2in 0 OFF
        
        ## rend la sortie du vérin automatique
        if {$run_sim == 1} {
            after 50 sortir_verin2
        } 
    } else {
        if {$boite2 != ""} {
            if {$x > 770 && $x < 795} {
                set list_tapis2 [lreplace $list_tapis2 $index2 $index2]
                .top.can delete $boite2
            }
            set boite2 ""
        }
        set Capt_v2_out 1
        setLed .top.captv2out 0 ON
    }
}

# --| rentrer_verin2 |-----------------------------------------------------------
# paramètre l_depl_v2 : longueur du déplacement à effectuer
# -------------------------------------------------------------------------------
proc rentrer_verin2 {} {
    global l_depl_v2 Capt_v2_out Capt_v2_in run_sim

    if {$l_depl_v2 < 60} {
        .top.can move verin_h2 0 -3
        .top.can move verin_v2 0 -3
        set l_depl_v2 [expr $l_depl_v2 + 3]
        set Capt_v2_out 0
        setLed .top.captv2out 0 OFF
       
       ## rend la rentrée du vérin automatique
        if {$run_sim == 1} {
            after 50 rentrer_verin2
        } 
        
    } else {
        set Capt_v2_in 1
        setLed .top.captv2in 0 ON
    }
}


# -------------------------------------------------------------------------------
# Création des procédures pour faire bouger les tapis
# Une procedure par tapis pour permettre de bouger plusieurs
# tapis en même temps
# -------------------------------------------------------------------------------

# --| mov_tapis1 |---------------------------------------------------------------
# paramètre sens : sens du déplacement à effectuer
# 0 : vers la droite
# 1 : vers la gauche
# autre : repos
# -------------------------------------------------------------------------------
proc mov_tapis1 {sens} {
  global boite_tapis1 runningMode l_depl_tapis

  if {$sens == 0} {
      .top.can move $boite_tapis1 $l_depl_tapis 0
  } elseif {$sens == 1} {
      .top.can move $boite_tapis1 -$l_depl_tapis 0
  } else {
      return
  }
}

# --| mov_tapis2 |---------------------------------------------------------------
# paramètre sens : sens du déplacement à effectuer
# 0 : vers la droite
# 1 : vers la gauche
# autre : repos
# -------------------------------------------------------------------------------
proc mov_tapis2 {sens} {
  global list_tapis2 nbr_tour_t2 Capt_tapis2 runningMode l_depl_tapis

  if {$sens == 0} {
      for {set i 0} {$i < [llength $list_tapis2]} {incr i} {
          .top.can move [lindex $list_tapis2 $i] $l_depl_tapis 0
      }
      if {$nbr_tour_t2 >= 3} {
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
          .top.can move [lindex $list_tapis2 $i] -$l_depl_tapis 0
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
      set list_tapis2 [lreplace $list_tapis2 0 0]
  }
}


# -------------------------------------------------------------------------------
# Création des procédures pour la gestion des capteurs
# -------------------------------------------------------------------------------
# --| Capteur_Lg |-----------------------------------------------------------
# gestion du capteur d'avancement du tapis 2
# -------------------------------------------------------------------------------
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

# --| Capt_presence1 |----------------------------------------------------------
# procédure de gestion du capteur qui détecte la présence d'une boite
# en bout de tapis 1
# -------------------------------------------------------------------------------
proc Capt_presence1 {} {
    global boite_tapis1 Capt_pres_tapis1

    set x1_boite [lindex [.top.can coords $boite_tapis1] 0]
    set x2_boite [lindex [.top.can coords $boite_tapis1] 2]
 
#   if {$x2_boite > 210 && $x1_boite < 218}
    if {$x2_boite > 200 && $x1_boite < 208} {
        setLed .top.capt1 0 ON
        set Capt_pres_tapis1 1
    } else {
        setLed .top.capt1 0 OFF
        set Capt_pres_tapis1 0
    }

    after 10 Capt_presence1
}

# --| Capt_presence2 |----------------------------------------------------------
# procédure de gestion du capteur qui détecte la présence d'une boite
# en face du vérin1
# -------------------------------------------------------------------------------
proc Capt_presence2 {} {
    global list_tapis2 Capt_pres_v1

    set Capt_pres_v1 0
    setLed .top.capt2 0 OFF

    for {set i 0} {$i < [llength $list_tapis2]} {incr i} {
      set x1_boite [lindex [.top.can coords [lindex $list_tapis2 $i]] 0]
      set x2_boite [lindex [.top.can coords [lindex $list_tapis2 $i]] 2]
      set y_boite [lindex [.top.can coords [lindex $list_tapis2 $i]] 1]
 #    if {$x2_boite > 575 && $x1_boite < 580}
      if {$x2_boite > 560 && $x1_boite < 570} {
          if {$y_boite < 140} {
              setLed .top.capt2 0 ON
              set Capt_pres_v1 1
              break
          }
      }
    }

    after 10 Capt_presence2
}


# --| Capt_presence3 |----------------------------------------------------------
# procédure de gestion du capteur qui détecte la présence d'une boite
# en face du vérin2
# -------------------------------------------------------------------------------
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

# --| Capt_presence4 |----------------------------------------------------------
# procédure de gestion du capteur qui détecte la présence d'une boite
# en fin de tapis2
# -------------------------------------------------------------------------------
proc Capt_presence4 {} {
    global list_tapis2 Capt_pres_t2_out

    set Capt_pres_t2_out 0
    setLed .top.capt4 0 OFF

    for {set i 0} {$i < [llength $list_tapis2]} {incr i} {
      set x1_boite [lindex [.top.can coords [lindex $list_tapis2 $i]] 0]
      set x2_boite [lindex [.top.can coords [lindex $list_tapis2 $i]] 2]
      if {$x2_boite > 850 && $x1_boite < 855} {
          setLed .top.capt4 0 ON
          set Capt_pres_t2_out 1
          break
      }
    }

    after 10 Capt_presence4
}

# --| Gestion_boites |-----------------------------------------------------------
# procédure qui gère le passage des boites du tapis 1 au tapis 2
# -------------------------------------------------------------------------------
proc Gestion_boites {} {
    global boite_tapis1 list_tapis2
    
    set x_boite [lindex [.top.can coords $boite_tapis1] 0]

    if {$x_boite > 217} {
        lappend list_tapis2 $boite_tapis1
        set boite_tapis1 ""
    }

    after 10 Gestion_boites
}

# --| create_boite |-------------------------------------------------------------
# procédure pour créer une nouvelle boite sur le tapis 1
# -------------------------------------------------------------------------------
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




# --| CONFIGWAVES |-----------------------------------------------------------------------
# --  Add signals to the wave view in QuestaSim
# ----------------------------------------------------------------------------------------
proc ConfigWaves {} {
  # Delete all remaining signals in the wave view
  delete wave *

  array set signalList {
    S0_sti        out
    S1_sti        out
    S2_sti        out
    S3_sti        out
    S4_sti        out
    S5_sti        out
    S6_sti        out
    S7_sti        out
    Val_A_sti     out
    Val_B_sti     out
    L0_obs        in
    L1_obs        in
    L2_obs        in
    L3_obs        in
    L4_obs        in
    L5_obs        in
    L6_obs        in
    L7_obs        in
    Result_A_obs  in
    Result_B_obs  in
    Hex0_obs      in
    Hex1_obs      in
    seg7_obs      in
    Horloge_s     internal
  }

  add wave -group Internes
  add wave -group Entrees
  add wave -group Sorties
  add wave -group Internes

  # Add a the waves for each signal in the list
  foreach sigName [lsort -dictionary [array names signalList]] {

    echo $sigName

    set sigType $signalList($sigName)
    if {[string match "in" $sigType]} {
      set groupName Entrees
    } elseif {[string match "out" $sigType]} {
      set groupName Sorties
    } elseif {[string match "inout" $sigType]} {
      set groupName Bidirs
    } elseif {[string match "internal" $sigType]} {
      set groupName Internes
    }
    add wave -expand -group $groupName -noupdate -format Logic -label $sigName /console_sim/$sigName
  }

  add wave -group UUT -divider Inputs
  add wave -group UUT -in "uut/*"
  add wave -group UUT -divider Outputs
  add wave -group UUT -out "uut/*"
  add wave -group UUT -divider Internals
  add wave -group UUT -internal "uut/*"
  add wave -expand -group UUT

  # Configure the wave view
  configure wave -namecolwidth 140
  configure wave -valuecolwidth 80
  WaveRestoreZoom {0 ns} {2600 ns}

  # Restart the simulation (to refresh the wave view)
  restart -f
  wave refresh
}


# --| CONFIGBOARD |-----------------------------------------------------------------------
# --  Configure the board pins and enable the SUBD25 IOs.
# ----------------------------------------------------------------------------------------
proc ConfigBoard {} {
  # Global variables:
  #   - Addresses to configure pins 1 to 16
  #   - Address to enable the SUBD25 IOs
  #   - Address to read the version of the FPGA
  global adrConfPin adrSUBD25OE adrVersion adr80pCONNOE

  #                     +-----------------+
  #              ===0==>|                 |===0==> 
  #              ===0==>|     Console     |===0==> 
  #              ===0==>|       USB2      |===0==> 
  #                     |                 |
  #                     +-----------------+
  #                       /80p connector\
  #          Result_A, Result_B, Val_A, Val_B, 8xLeds 

  # Configuration for the left SUB25 connector
  #   - Pin(s) 01 to 08 as inputs  # 
  #   - Pin(s) 09 to 16 as inputs  # 
  #   - Pin(s) 17 to 24 as inputs  # 
  #   - Pins left (25 to 27) as inputs
  set ConfigPinG01_08 [format %d 0x00]; # 0000 0000
  set ConfigPinG09_16 [format %d 0x00]; # 0000 0000
  set ConfigPinG17_24 [format %d 0x00]; # 0000 0000
  set ConfigPinG25_27 [format %d 0x00]; # 0000 0000

  #EcrireUSB $adrConfPin(G01_08) $ConfigPinG01_08
  #EcrireUSB $adrConfPin(G09_16) $ConfigPinG09_16
  #EcrireUSB $adrConfPin(G17_24) $ConfigPinG17_24
  #EcrireUSB $adrConfPin(G25_27) $ConfigPinG25_27

  # Configuration for the right SUB25 connector
  #   - Pin(s) 01 to 08 as inputs  # 
  #   - Pin(s) 09 to 16 as inputs  # 
  #   - Pin(s) 17 to 24 as inputs  # 
  #   - Pins left (25 to 27) as inputs
  set ConfigPinD01_08 [format %d 0xFF]; # 1111 1111
  set ConfigPinD09_16 [format %d 0xFF]; # 1111 1111
  set ConfigPinD17_24 [format %d 0x00]; # 0000 0000
  set ConfigPinD25_27 [format %d 0x00]; # 0000 0000

  EcrireUSB $adrConfPin(D01_08) $ConfigPinD01_08
  EcrireUSB $adrConfPin(D09_16) $ConfigPinD09_16
  EcrireUSB $adrConfPin(D17_24) $ConfigPinD17_24
  EcrireUSB $adrConfPin(D25_27) $ConfigPinD25_27
  
  EcrireUSB $adrConfPin(G01_08) $ConfigPinD01_08
  EcrireUSB $adrConfPin(G09_16) $ConfigPinD09_16
  EcrireUSB $adrConfPin(G17_24) $ConfigPinD17_24
  EcrireUSB $adrConfPin(G25_27) $ConfigPinD25_27
  
   # Configuration for the 80p connector
   # - Pin(s) 01           as input  # gnd            | 80pConnPort1
   # - Pin(s) 08 downto 02 as inputs # Leds           | 80pConnPort1
   # - Pin(s) 16 downto 09 as inputs # Result_A( 7:0) | 80pConnPort2
   # - Pin(s) 24 downto 17 as inputs # Result_A(15:8) | 80pConnPort3
   # - Pin(s) 32 downto 25 as inputs # Result_B( 7:0) | 80pConnPort4
   # - Pin(s) 40 downto 33 as inputs # Result_B(15:8) | 80pConnPort5
   # - Pin(s) 48 downto 41 as outputs # Val_A(7:0)    | 80pConnPort6
   # - Pin(s) 56 downto 49 as outputs # Val_A(15:8)   | 80pConnPort7
   # - Pin(s) 64 downto 57 as outputs # Val_B(7:0)    | 80pConnPort8
   # - Pin(s) 72 downto 65 as outputs # Val_B(15:8)   | 80pConnPort9
   # - Pin(s) 80 downto 73 as inputs  #               | 80pConnPort10
   # - Pins left as inputs
  set ConfPin80pConnPort1  [format %d 0x00]; # 0000 0000 
  set ConfPin80pConnPort2  [format %d 0x00]; # 0000 0000
  set ConfPin80pConnPort3  [format %d 0x00]; # 0000 0000
  set ConfPin80pConnPort4  [format %d 0x00]; # 0000 0000
  set ConfPin80pConnPort5  [format %d 0x00]; # 0000 0000
  set ConfPin80pConnPort6  [format %d 0xFF]; # 1111 1111
  set ConfPin80pConnPort7  [format %d 0xFF]; # 1111 1111
  set ConfPin80pConnPort8  [format %d 0xFF]; # 1111 1111
  set ConfPin80pConnPort9  [format %d 0xFF]; # 1111 1111
  set ConfPin80pConnPort10 [format %d 0x00]; # 0000 0000 ,pin 80 connectee au gnd!
  
  EcrireUSB $adrConfPin(80pConnPort1) $ConfPin80pConnPort1
  EcrireUSB $adrConfPin(80pConnPort2) $ConfPin80pConnPort2
  EcrireUSB $adrConfPin(80pConnPort3) $ConfPin80pConnPort3
  EcrireUSB $adrConfPin(80pConnPort4) $ConfPin80pConnPort4
  EcrireUSB $adrConfPin(80pConnPort5) $ConfPin80pConnPort5
  EcrireUSB $adrConfPin(80pConnPort6) $ConfPin80pConnPort6
  EcrireUSB $adrConfPin(80pConnPort7) $ConfPin80pConnPort7
  EcrireUSB $adrConfPin(80pConnPort8) $ConfPin80pConnPort8
  EcrireUSB $adrConfPin(80pConnPort9) $ConfPin80pConnPort9
  EcrireUSB $adrConfPin(80pConnPort10) $ConfPin80pConnPort10

  puts "ConfigPort 80p"
  
  # Read and display the version of the FPGA. Also warn the user to configure the
  # board EMP7128S correctly.
  set FPGAVERSION [LireUSB $adrVersion]
  set ttl "! ATTENTION, RISQUE DE COURT-CIRCUIT !"
  set msg "! ATTENTION, RISQUE DE COURT-CIRCUIT !\n\n\
           Veuillez controler que les contraintes des pins de la CPLD aient ete faites \
           correctement.\n Une fois ce controle effectue, cliquez sur \"OK\".\n\n\
           Console USB2, FPGA Version $FPGAVERSION"
  set answer [tk_messageBox -type okcancel -default cancel -icon warning -title $ttl -message $msg]
  switch -- $answer {
    cancel QuitConsole
  }

  # Enable the IOs for SUBD25
   EcrireUSB $adrSUBD25OE 0
  # Enable the IOs for 80pCONN
  #EcrireUSB $adr80pCONNOE 0
}

# ----------------------------------------------------------------------------------------
# -- Programme principal /////////////////////////////////////////////////////////////////
# ----------------------------------------------------------------------------------------
CheckRunningMode
 puts "running mode"
SetVariables
puts "Set Variables"
CreateMainWindow
if {$runningMode == "Simulation"} {
  #ConfigWaves
} else {
  ConfigBoard
  puts "Config Board"
}
#SetOutputs
Capteur_Lg
puts "Capteur Lg"
Capt_presence1
Capt_presence2
Capt_presence3
Capt_presence4
Gestion_boites
puts "Gestion_Boites"
