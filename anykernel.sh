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
  ui_print "Detected sideload, using manual configuration..."
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

    # Handle UI variant (AOSP or MIUI)
    case "$UI_VARIANT" in
      miui)
        ui_print "MIUI/HyperOS variant Identified"
        ui_print "---> Applying MIUI/HOS DTBO..."
        mv *-miui-dtbo.img $home/dtbo.img
        rm -f *-aosp-dtbo.img
        ;;
      aosp)
        ui_print "AOSP variant Identified"
        ui_print "---> Applying AOSP DTBO..."
        mv *-aosp-dtbo.img $home/dtbo.img
        rm -f *-miui-dtbo.img
        ;;
      *)
        ui_print "No specific variant detected !!!"
        ui_print "---> Applying AOSP DTBO..."
        mv *-aosp-dtbo.img $home/dtbo.img
        rm -f *-miui-dtbo.img
        ;;
    esac
    ui_print " ";

    # Handle CPU variant
    case "$CPU_VARIANT" in
      eff)
        ui_print "Efficient CPU variant detected"
        ui_print "---> Applying Efficient CPU variant..."
        mv *-effcpu-dtb $home/dtb
        rm -f *-normal-dtb
        ;;
      *)
        ui_print "Normal CPU variant detected"
        ui_print "---> Applying Normal CPU variant..."
        mv *-normal-dtb $home/dtb
        rm -f *-effcpu-dtb
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
      ui_print "MIUI/HyperOS variant identified,";
      ui_print "---> Applying MIUI DTBO... ";
      mv *-miui-dtbo.img $home/dtbo.img;
      rm *-aosp-dtbo.img;
    ;;
    *aosp*|*AOSP*)
      ui_print "AOSP variant identified,";
      ui_print "---> Applying AOSP DTBO... ";
      mv *-aosp-dtbo.img $home/dtbo.img;
      rm *-miui-dtbo.img;
    ;;
    *)
      ui_print "No specific variant detected !!!";
      ui_print "---> Applying AOSP DTBO... ";
      mv *-aosp-dtbo.img $home/dtbo.img;
      rm *-miui-dtbo.img;
    ;;
  esac
  ui_print " ";

  case "$ZIPFILE" in
    *eff*|*EFF*)
      ui_print "Efficient CPU variant identified,";
      ui_print "---> Applying Efficient CPU variant...";
      mv *-effcpu-dtb $home/dtb;
      rm *-normal-dtb;
    ;;
    *)
      ui_print "Normal CPU variant identified,";
      ui_print "---> Applying Normal CPU variant...";
      mv *-normal-dtb $home/dtb;
      rm *-effcpu-dtb;
    ;;
  esac
fi

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
