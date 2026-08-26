#!/usr/bin/env python3
import json
import subprocess
import time

def get_monitors():
    try:
        output = subprocess.check_output(["hyprctl", "monitors", "-j"]).decode("utf-8")
        monitors = json.loads(output)
        return [m.get("name") for m in monitors if m.get("name")]
    except Exception:
        return []

def main():
    # Finalizar cualquier proceso previo de nwg-dock-hyprland
    subprocess.run(["pkill", "-f", "nwg-dock-hyprland"], check=False)
    time.sleep(0.5)

    monitors = get_monitors()
    if not monitors:
        # En caso de error al obtener monitores, lanzar una sola instancia por defecto
        subprocess.Popen(["nwg-dock-hyprland", "-d", "-p", "bottom", "-i", "32", "-mb", "10"])
        return

    # Iniciar una instancia del dock para cada monitor conectado
    for monitor in monitors:
        subprocess.Popen([
            "nwg-dock-hyprland",
            "-d",
            "-p", "bottom",
            "-i", "32",
            "-mb", "10",
            "-o", monitor,
            "-m"
        ])

if __name__ == "__main__":
    main()
