#!/usr/bin/env python3
import json
import subprocess
import sys

def get_status():
    try:
        output = subprocess.check_output(["hyprctl", "devices", "-j"]).decode("utf-8")
        devices = json.loads(output)
        keyboards = devices.get("keyboards", [])
        
        # Find the main keyboard or fallback to a keyboard with layout rules
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
            return "US", False
            
        keymap = main_kb.get("active_keymap", "")
        layout = "US"
        if "latin" in keymap.lower() or "spanish" in keymap.lower() or "latam" in keymap.lower():
            layout = "LA"
            
        # Check if capsLock is active on any keyboard
        caps_lock = any(kb.get("capsLock", False) for kb in keyboards)
        
        return layout, caps_lock
    except Exception as e:
        return "US", False

def main():
    layout, caps_lock = get_status()
    icon = "\U000f05ca"  # 󰗊 md-translate
    
    css_class = layout.lower()
    if caps_lock:
        css_class += " caps"
        
    layout_name = "Español Latinoamericano (LA)" if layout == "LA" else "Inglés Estados Unidos (US)"
    caps_text = "Activo" if caps_lock else "Desactivado"
    tooltip = f"Distribución: {layout_name}\nBloq Mayús: {caps_text}\nClic para cambiar"
    
    data = {
        "text": icon,
        "tooltip": tooltip,
        "class": css_class
    }
    print(json.dumps(data))

if __name__ == "__main__":
    main()
