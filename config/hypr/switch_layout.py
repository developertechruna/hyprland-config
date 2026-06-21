#!/usr/bin/env python3
import json
import subprocess

def get_current_layout():
    try:
        # Query again to get the updated status
        output = subprocess.check_output(["hyprctl", "devices", "-j"]).decode("utf-8")
        devices = json.loads(output)
        keyboards = devices.get("keyboards", [])
        
        main_kb = None
        for kb in keyboards:
            if kb.get("main"):
                main_kb = kb
                break
        if not main_kb and keyboards:
            for kb in keyboards:
                if kb.get("layout"):
                    main_kb = kb
                    break
        if not main_kb and keyboards:
            main_kb = keyboards[0]
            
        if not main_kb:
            return "US"
            
        keymap = main_kb.get("active_keymap", "")
        if "latin" in keymap.lower() or "spanish" in keymap.lower() or "latam" in keymap.lower():
            return "LA"
        return "US"
    except Exception:
        return "US"

def main():
    try:
        # Get list of devices in JSON format
        output = subprocess.check_output(["hyprctl", "devices", "-j"]).decode("utf-8")
        devices = json.loads(output)
        
        # Iterate over all keyboards and switch layout to next
        keyboards = devices.get("keyboards", [])
        for k in keyboards:
            name = k.get("name")
            if name:
                subprocess.run(["hyprctl", "switchxkblayout", name, "next"], check=False)
        
        # Get new layout
        new_layout = get_current_layout()
        
        # Send desktop notification
        # Use -r to replace the previous notification to avoid spamming the screen
        subprocess.run([
            "notify-send", 
            "-t", "1500", 
            "-r", "9910", 
            "-i", "input-keyboard", 
            "Distribución de Teclado", 
            f"Cambiado a: {new_layout}"
        ], check=False)
        
        # Signal Waybar to refresh the custom module instantly
        subprocess.run(["pkill", "-RTMIN+1", "waybar"], check=False)
        
    except Exception as e:
        print(f"Error switching layout: {e}")

if __name__ == "__main__":
    main()
