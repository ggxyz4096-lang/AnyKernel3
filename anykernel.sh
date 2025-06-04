# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers

# FusionX kernel custom installer by SenX

# Big thanks to these guys from whom i've taken ideas.
# @KaminariKo (FakeDreamer Kernel) and @sk113r (E404 kernel)

## AnyKernel setup
# begin properties
properties() { '
kernel.string=FusionX by SenX (@WazzupSensei911) --Telegram
do.devicecheck=1
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=munch
device.name2=munchin
device.name3=
device.name4=
device.name5=
supported.versions=
'; } # end properties

# shell variables
block=/dev/block/bootdevice/by-name/boot;
is_slot_device=1;
ramdisk_compression=auto;

## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. tools/ak3-core.sh;

## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
set_perm_recursive 0 0 750 750 $ramdisk/*;

ui_print " ";
ui_print "╔══════════════════════════════════════════╗";
ui_print "║        F U S I O N X  K E R N E L        ║";
ui_print "║           Powering your Device           ║";
ui_print "╚══════════════════════════════════════════╝";
ui_print " ";

# Check if we're in sideload mode
if { [ "$(basename "$ZIPFILE")" = "update.zip" ] || [ "$(basename "$ZIPFILE")" = "package.zip" ]; }; then
  SIDELOAD=1;
  ui_print "Sideload installation detected";
  ui_print " ";
else
  SIDELOAD=0;
fi;

manual_install() {
  ui_print " ";
  ui_print "> UI Variant: MIUI/HyperOS (Vol +) || AOSP (Vol -) ";
  while true; do
    ev=$(getevent -lt 2>/dev/null | grep -m1 "KEY_VOLUME.*DOWN")
    case $ev in
      *KEY_VOLUMEUP*)
        ui_print "┌─────────────────────────────────┐";
        ui_print "│      MIUI/HyperOS Selected      │";
        ui_print "└─────────────────────────────────┘";
        if [ -f *-miui-dtbo.img ]; then
          ui_print "◉ Applying kernel for MIUI/HyperOS...";
          mv *-miui-dtbo.img $home/dtbo.img;
          rm -f *-aosp-dtbo.img *-aosp-ir-dtbo.img;
        else
          abort "ERROR: MIUI dtbo image not found!";
        fi
        break 
        ;;
      *KEY_VOLUMEDOWN*)
        # AOSP selected, now ask about IR
        ui_print "┌─────────────────────────────────┐";
        ui_print "│        AOSP Selected            │";
        ui_print "└─────────────────────────────────┘";
        ui_print "◉ Applying kernel for AOSP-based ROMs...";
        ui_print " ";
        ui_print "> IR Blaster: New LOS-IR (Vol +) || Old IR (Vol -) ";
        while true; do
          ev=$(getevent -lt 2>/dev/null | grep -m1 "KEY_VOLUME.*DOWN")
          case $ev in
            *KEY_VOLUMEUP*)
              ui_print "◉ New LineageOS IR implementation selected";
              if [ -f *-aosp-ir-dtbo.img ]; then
                mv *-aosp-ir-dtbo.img $home/dtbo.img;
                rm -f *-aosp-dtbo.img *-miui-dtbo.img;
              else
                abort "ERROR: AOSP-IR dtbo image not found!";
              fi
              break 
              ;;
            *KEY_VOLUMEDOWN*)
              ui_print "◉ Old IR implementation selected";
              if [ -f *-aosp-dtbo.img ]; then
                mv *-aosp-dtbo.img $home/dtbo.img;
                rm -f *-miui-dtbo.img *-aosp-ir-dtbo.img;
              else
                abort "ERROR: AOSP dtbo image not found!";
              fi
              break 
              ;;
          esac
        done
        break 
        ;;
    esac
  done
  ui_print " ";

  ui_print "> CPU Mode: Efficient (Vol +) || Normal (Vol -) ";
  while true; do
    ev=$(getevent -lt 2>/dev/null | grep -m1 "KEY_VOLUME.*DOWN")
    case $ev in
      *KEY_VOLUMEUP*)
        ui_print "┌─────────────────────────────────┐";
        ui_print "│     Efficient Mode Enabled      │";
        ui_print "└─────────────────────────────────┘";
        ui_print "◉ Applying power-efficient CPU configuration...";
        if [ -f *-effcpu-dtb ]; then
          mv *-effcpu-dtb $home/dtb;
          rm -f *-normal-dtb *-slight-uc-dtb;
        else
          abort "ERROR: Efficient CPU DTB not found!";
        fi
        break;
        ;;
      *KEY_VOLUMEDOWN*)
        # Normal selected, now ask about frequency
        ui_print "┌─────────────────────────────────┐";
        ui_print "│      Normal Mode Selected       │";
        ui_print "└─────────────────────────────────┘";
        ui_print " ";
        ui_print "> CPU Frequency: 3.2GHz (Vol +) || 2.8GHz (Vol -) ";
        while true; do
          ev=$(getevent -lt 2>/dev/null | grep -m1 "KEY_VOLUME.*DOWN")
          case $ev in
            *KEY_VOLUMEUP*)
              ui_print "◉ Maximum performance selected - 3.2GHz";
              if [ -f *-normal-dtb ]; then
                mv *-normal-dtb $home/dtb;
                rm -f *-effcpu-dtb *-slight-uc-dtb;
              else
                abort "ERROR: Max CPU DTB not found!";
              fi
              break 
              ;;
            *KEY_VOLUMEDOWN*)
              ui_print "◉ Balanced performance selected - 2.8GHz";
              if [ -f *-slight-uc-dtb ]; then
                mv *-slight-uc-dtb $home/dtb;
                rm -f *-effcpu-dtb *-normal-dtb;
              else
                abort "ERROR: Underclocked CPU DTB not found!";
              fi
              break 
              ;;
          esac
        done
        break 
        ;;
    esac
  done
}

# Auto installation based on filename
auto_install() {
  ui_print " ";
  case "$ZIPFILE" in
    *miui*|*MIUI*)
      ui_print "┌─────────────────────────────────┐";
      ui_print "│    MIUI/HyperOS ROM Detected    │";
      ui_print "└─────────────────────────────────┘";
      ui_print "◉ Applying kernel for MIUI/HyperOS...";
      if [ -f *-miui-dtbo.img ]; then
        mv *-miui-dtbo.img $home/dtbo.img;
        rm -f *-aosp-dtbo.img *-aosp-ir-dtbo.img;
      else
        abort "ERROR: MIUI dtbo image not found!";
      fi
      ;;
    *ir*|*IR*)
      ui_print "┌─────────────────────────────────┐";
      ui_print "│     AOSP with New IR Detected   │";
      ui_print "└─────────────────────────────────┘";
      ui_print "◉ Applying New LineageOS IR implementation...";
      if [ -f *-aosp-ir-dtbo.img ]; then
        mv *-aosp-ir-dtbo.img $home/dtbo.img;
        rm -f *-aosp-dtbo.img *-miui-dtbo.img;
      else
        abort "ERROR: AOSP-IR dtbo image not found!";
      fi
      ;;
    *aosp*|*AOSP*)
      ui_print "┌─────────────────────────────────┐";
      ui_print "│       AOSP ROM Detected         │";
      ui_print "└─────────────────────────────────┘";
      ui_print "◉ Applying kernel for AOSP...";
      ui_print "◉ Using Old IR implementation...";
      if [ -f *-aosp-dtbo.img ]; then
        mv *-aosp-dtbo.img $home/dtbo.img;
        rm -f *-miui-dtbo.img *-aosp-ir-dtbo.img;
      else
        abort "ERROR: AOSP dtbo image not found!";
      fi
      ;;
    *)
      ui_print "┌─────────────────────────────────┐";
      ui_print "│  No Specific Variant Detected!! │";
      ui_print "└─────────────────────────────────┘";
      ui_print "◉ Applying default AOSP configuration...";
      if [ -f *-aosp-dtbo.img ]; then
        mv *-aosp-dtbo.img $home/dtbo.img;
        rm -f *-miui-dtbo.img *-aosp-ir-dtbo.img;
      else
        abort "ERROR: Default AOSP dtbo image not found!";
      fi
      ;;
  esac
  ui_print " ";

  case "$ZIPFILE" in
    *eff*|*EFF*)
      ui_print "┌─────────────────────────────────┐";
      ui_print "│     Efficient Mode Enabled      │";
      ui_print "└─────────────────────────────────┘";
      ui_print "◉ Applying power-efficient CPU frequency...";
      if [ -f *-effcpu-dtb ]; then
        mv *-effcpu-dtb $home/dtb;
        rm -f *-normal-dtb *-slight-uc-dtb;
      else
        abort "ERROR: Efficient CPU DTB not found!";
      fi
      ;;
    *bal*|*BAL*)
      ui_print "┌─────────────────────────────────┐";
      ui_print "│     Balance Mode - 2.8GHz       │";
      ui_print "└─────────────────────────────────┘";
      ui_print "◉ Applying balance CPU frequency...";
      if [ -f *-slight-uc-dtb ]; then
        mv *-slight-uc-dtb $home/dtb;
        rm -f *-effcpu-dtb *-normal-dtb;
      else
        abort "ERROR: Underclocked CPU DTB not found!";
      fi
      ;;
    *)
      ui_print "┌─────────────────────────────────┐";
      ui_print "│   Performance Mode - 3.2GHz     │";
      ui_print "└─────────────────────────────────┘";
      ui_print "◉ Applying maximum CPU frequency...";
      if [ -f *-normal-dtb ]; then
        mv *-normal-dtb $home/dtb;
        rm -f *-effcpu-dtb *-slight-uc-dtb;
      else
        abort "ERROR: Max CPU DTB not found!";
      fi
      ;;
  esac
}

# Process .fusionX file configuration
process_fusionx_file() {
  FUSIONX_FILE=$(find . -type f -name "*.fusionX" | head -n 1)

  if [ -n "$FUSIONX_FILE" ]; then
    ui_print "Detected .fusionX file: $FUSIONX_FILE"
    ui_print " ";
    
    FILE_NAME=$(basename "$FUSIONX_FILE")
    FILE_NAME_NO_EXT=$(echo "$FILE_NAME" | sed 's/\.fusionX$//')
    
    UI_VARIANT=$(echo "$FILE_NAME_NO_EXT" | cut -d'-' -f1)
    CPU_VARIANT=$(echo "$FILE_NAME_NO_EXT" | cut -d'-' -f2)
    
    ui_print "ROM configuration: $UI_VARIANT"
    ui_print "CPU configuration: $CPU_VARIANT"
    ui_print " ";

    # Handle UI variant (AOSP, MIUI, or LOS)
    case "$UI_VARIANT" in
      miui)
        ui_print "┌─────────────────────────────────┐";
        ui_print "│    MIUI/HyperOS ROM Detected    │";
        ui_print "└─────────────────────────────────┘";
        ui_print "◉ Applying kernel for MIUI/HyperOS...";
        if [ -f *-miui-dtbo.img ]; then
          mv *-miui-dtbo.img $home/dtbo.img;
          rm -f *-aosp-dtbo.img *-aosp-ir-dtbo.img;
        else
          abort "ERROR: MIUI dtbo image not found!";
        fi
        ;;
      ir)
        ui_print "┌─────────────────────────────────┐";
        ui_print "│    New LineageOS IR Detected    │";
        ui_print "└─────────────────────────────────┘";
        ui_print "◉ Applying New LineageOS IR implementation...";
        if [ -f *-aosp-ir-dtbo.img ]; then
          mv *-aosp-ir-dtbo.img $home/dtbo.img;
          rm -f *-aosp-dtbo.img *-miui-dtbo.img;
        else
          abort "ERROR: AOSP-IR dtbo image not found!";
        fi
        ;;
      aosp)
        ui_print "┌─────────────────────────────────┐";
        ui_print "│       AOSP ROM Detected         │";
        ui_print "└─────────────────────────────────┘";
        ui_print "◉ Applying kernel for AOSP...";
        ui_print "◉ Using Old IR implementation...";
        if [ -f *-aosp-dtbo.img ]; then
          mv *-aosp-dtbo.img $home/dtbo.img;
          rm -f *-miui-dtbo.img *-aosp-ir-dtbo.img;
        else
          abort "ERROR: AOSP dtbo image not found!";
        fi
        ;;
      *)
      ui_print "┌─────────────────────────────────┐";
      ui_print "│  No Specific Variant Detected!! │";
      ui_print "└─────────────────────────────────┘";
      ui_print "◉ Applying default AOSP configuration...";
        if [ -f *-aosp-dtbo.img ]; then
          mv *-aosp-dtbo.img $home/dtbo.img;
          rm -f *-miui-dtbo.img *-aosp-ir-dtbo.img;
        else
          abort "ERROR: Default AOSP dtbo image not found!";
        fi
        ;;
    esac
    ui_print " ";

    # Handle CPU variant
    case "$CPU_VARIANT" in
      eff)
        ui_print "┌─────────────────────────────────┐";
        ui_print "│     Efficient Mode Enabled      │";
        ui_print "└─────────────────────────────────┘";
        ui_print "◉ Applying power-efficient CPU frequency...";
        if [ -f *-effcpu-dtb ]; then
          mv *-effcpu-dtb $home/dtb;
          rm -f *-normal-dtb *-slight-uc-dtb;
        else
          abort "ERROR: Efficient CPU DTB not found!";
        fi
        ;;
      bal)
        ui_print "┌─────────────────────────────────┐";
        ui_print "│     Balance Mode - 2.8GHz       │";
        ui_print "└─────────────────────────────────┘";
        ui_print "◉ Applying balance CPU frequency...";
        if [ -f *-slight-uc-dtb ]; then
          mv *-slight-uc-dtb $home/dtb;
          rm -f *-effcpu-dtb *-normal-dtb;
        else
          abort "ERROR: Slight UC CPU DTB not found!";
        fi
        ;;
      *)
        ui_print "┌─────────────────────────────────┐";
        ui_print "│   Performance Mode - 3.2GHz     │";
        ui_print "└─────────────────────────────────┘";
        ui_print "◉ Applying maximum CPU frequency...";
        if [ -f *-normal-dtb ]; then
          mv *-normal-dtb $home/dtb;
          rm -f *-effcpu-dtb *-slight-uc-dtb;
        else
          abort "ERROR: Max CPU DTB not found!";
        fi
        ;;
    esac

    # Optionally delete .fusionX file after processing (clean-up)
    rm -f "$FUSIONX_FILE"
    return 0
  else
    ui_print "No configuration file found - proceeding with automatic detection";
    return 1
  fi
}

# Show selection for installation method
ui_print "> Installation Mode: Manual (Vol +) || Auto (Vol -) ";

# Wait for user input without timeout
while true; do
  ev=$(getevent -lt 2>/dev/null | grep -m1 "KEY_VOLUME.*DOWN")
  case $ev in
    *KEY_VOLUMEUP*)
      ui_print "◉ Manual installation selected";
      INSTALL_METHOD="manual"
      break
      ;;
    *KEY_VOLUMEDOWN*)
      ui_print "◉ Automatic installation selected";
      INSTALL_METHOD="auto"
      break
      ;;
  esac
done

# Handle the installation based on the chosen method
if [ "$INSTALL_METHOD" = "manual" ]; then
  manual_install
elif [ "$INSTALL_METHOD" = "auto" ]; then
  if [ "$SIDELOAD" = "1" ] && process_fusionx_file; then
    ui_print "Using configuration from setup file";
  else
    auto_install
  fi
fi

if [ ! -f /vendor/etc/task_profiles.json ] && [ ! -f /system/vendor/etc/task_profiles.json ]; then
  ui_print " ";
  ui_print "Notice: Task profiles not found on your ROM";
  ui_print "Consider installing Uclamp task profiles module for optimal performance";
  ui_print "You can ignore this message if already installed";
  ui_print " ";
fi;

## AnyKernel install
dump_boot;

# Begin Ramdisk Changes

# migrate from /overlay to /overlay.d to enable SAR Magisk
if [ -d $ramdisk/overlay ]; then
  rm -rf $ramdisk/overlay;
fi;

write_boot;
## end install

## vendor_boot shell variables
block=/dev/block/bootdevice/by-name/vendor_boot;
is_slot_device=1;
ramdisk_compression=auto;
patch_vbmeta_flag=auto;

# reset for vendor_boot patching
reset_ak;

# vendor_boot install
dump_boot;

write_boot;
## end vendor_boot install