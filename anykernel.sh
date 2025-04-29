# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers

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

# kernel naming scene
ui_print " ";
ui_print "╔══════════════════════════════════════════╗";
ui_print "║        F U S I O N X  K E R N E L        ║";
ui_print "║           Powering your Device           ║";
ui_print "╚══════════════════════════════════════════╝";
ui_print " ";

# Check if we are using sideload with 'update.zip' or 'package.zip' and if sideload.txt exists
if { [ "$(basename "$ZIPFILE")" = "update.zip" ] || [ "$(basename "$ZIPFILE")" = "package.zip" ]; }; then
  ui_print "Sideload detected, using manual configuration..."
  ui_print " ";

  # Detect .fusionX file and analyze the filename
  FUSIONX_FILE=$(find . -type f -name "*.fusionX" | head -n 1)

  if [ -n "$FUSIONX_FILE" ]; then
    ui_print "Detected .fusionX file: $FUSIONX_FILE"
    ui_print " ";
    
    # Extract filename from the .fusionX file and remove the '.fusionX' extension
    FILE_NAME=$(basename "$FUSIONX_FILE")
    FILE_NAME_NO_EXT=$(echo "$FILE_NAME" | sed 's/\.fusionX$//')
    
    # Now split the filename without the extension
    UI_VARIANT=$(echo "$FILE_NAME_NO_EXT" | cut -d'-' -f1)
    CPU_VARIANT=$(echo "$FILE_NAME_NO_EXT" | cut -d'-' -f2)
    
    # Log the parsed variants
    ui_print "UI variant: $UI_VARIANT"
    ui_print "CPU variant: $CPU_VARIANT"
    ui_print " ";

    # Handle UI variant (AOSP, MIUI, or LOS)
    case "$UI_VARIANT" in
      miui)
        ui_print "┌─────────────────────────────────┐";
        ui_print "│   MIUI/HyperOS ROM Detected     │";
        ui_print "└─────────────────────────────────┘";
        ui_print " ";
        ui_print "--→ Optimizing kernel for MIUI/HOS...";
        mv *-miui-dtbo.img $home/dtbo.img;
        rm -f *-aosp-dtbo.img *-los-dtbo.img;
        ;;
      los)
        ui_print "┌─────────────────────────────────┐";
        ui_print "│     LineageOS IR Detected       │";
        ui_print "└─────────────────────────────────┘";
        ui_print " ";
        ui_print "--→ Using Lineage Ir Blaster...";
        mv *-los-dtbo.img $home/dtbo.img;
        rm -f *-aosp-dtbo.img *-miui-dtbo.img;
        ;;
      aosp)
        ui_print "┌─────────────────────────────────┐";
        ui_print "│       AOSP ROM Detected         │";
        ui_print "└─────────────────────────────────┘";
        ui_print " ";
        ui_print "--→ Optimizing kernel for AOSP...";
        mv *-aosp-dtbo.img $home/dtbo.img;
        rm -f *-miui-dtbo.img *-los-dtbo.img;
        ;;
      *)
        ui_print "┌─────────────────────────────────┐";
        ui_print "│  No Specific Variant Detected!! │";
        ui_print "└─────────────────────────────────┘";
        ui_print " ";
        ui_print "--→ Applying default AOSP configuration...";
        mv *-aosp-dtbo.img $home/dtbo.img;
        rm -f *-miui-dtbo.img *-los-dtbo.img;
        ;;
    esac
    ui_print " ";

    # Handle CPU variant
    case "$CPU_VARIANT" in
      eff)
        ui_print "┌─────────────────────────────────┐";
        ui_print "│   Efficient CPU Mode Enabled    │";
        ui_print "└─────────────────────────────────┘";
        ui_print " ";
        ui_print "--→ Applying efficient cpu optimizations...";
        mv *-effcpu-dtb $home/dtb;
        rm -f *-normal-dtb;
        ;;
      *)
        ui_print "┌─────────────────────────────────┐";
        ui_print "│    Normal CPU Mode Enabled      │";
        ui_print "└─────────────────────────────────┘";
        ui_print " ";
        ui_print "--→ Applying normal cpu settings...";
        mv *-normal-dtb $home/dtb;
        rm -f *-effcpu-dtb;
        ;;
    esac

    # Optionally delete .fusionX file after processing (clean-up)
    rm -f "$FUSIONX_FILE"
  else
    abort "ERROR!!! No .fusionX file found in zip."
  fi
else
  case "$ZIPFILE" in
    *miui*|*MIUI*)
      ui_print "┌─────────────────────────────────┐";
      ui_print "│   MIUI/HyperOS ROM Detected     │";
      ui_print "└─────────────────────────────────┘";
      ui_print " ";
      ui_print "--→ Optimizing kernel for MIUI/HOS...";
      mv *-miui-dtbo.img $home/dtbo.img;
      rm -f *-aosp-dtbo.img *-los-dtbo.img;
      ;;
    *los*|*LOS*)
      ui_print "┌─────────────────────────────────┐";
      ui_print "│     LineageOS IR Detected      │";
      ui_print "└─────────────────────────────────┘";
      ui_print " ";
      ui_print "--→ Using Lineage Ir Blaster...";
      mv *-los-dtbo.img $home/dtbo.img;
      rm -f *-aosp-dtbo.img *-miui-dtbo.img;
      ;;
    *aosp*|*AOSP*)
      ui_print "┌─────────────────────────────────┐";
      ui_print "│       AOSP ROM Detected         │";
      ui_print "└─────────────────────────────────┘";
      ui_print " ";
      ui_print "--→ Optimizing kernel for AOSP...";
      mv *-aosp-dtbo.img $home/dtbo.img;
      rm -f *-miui-dtbo.img *-los-dtbo.img;
      ;;
    *)
      ui_print "┌─────────────────────────────────┐";
      ui_print "│  No Specific Variant Detected!! │";
      ui_print "└─────────────────────────────────┘";
      ui_print " ";
      ui_print "--→ Applying default AOSP configuration...";
      mv *-aosp-dtbo.img $home/dtbo.img;
      rm -f *-miui-dtbo.img *-los-dtbo.img;
      ;;
  esac
  ui_print " ";

  case "$ZIPFILE" in
    *eff*|*EFF*)
      ui_print "┌─────────────────────────────────┐";
      ui_print "│   Efficient CPU Mode Enabled    │";
      ui_print "└─────────────────────────────────┘";
      ui_print " ";
      ui_print "--→ Applying efficient cpu optimizations...";
      mv *-effcpu-dtb $home/dtb;
      rm -f *-normal-dtb;
      ;;
    *)
      ui_print "┌─────────────────────────────────┐";
      ui_print "│    Normal CPU Mode Enabled      │";
      ui_print "└─────────────────────────────────┘";
      ui_print " ";
      ui_print "--→ Applying normal cpu settings...";
      mv *-normal-dtb $home/dtb;
      rm -f *-effcpu-dtb;
      ;;
  esac
fi

# Uclamp check
if [ ! -f /vendor/etc/task_profiles.json ] && [ ! -f /system/vendor/etc/task_profiles.json ]; then
  ui_print " ";
  ui_print "Your rom does not have Uclamp task profiles !";
  ui_print "Please install Uclamp task profiles module !";
  ui_print "--→ Ignore this if you already have.";
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
