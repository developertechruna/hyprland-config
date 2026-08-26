#!/usr/bin/env python3
import subprocess
import json
import os
import time

def get_focused_monitor():
    try:
        output = subprocess.check_output(["hyprctl", "monitors", "-j"]).decode("utf-8")
        monitors = json.loads(output)
        for m in monitors:
            if m.get("focused"):
                return m.get("name")
    except Exception:
        pass
    return None

def find_dock_process(monitor_name):
    # Buscar en /proc los procesos nwg-dock-hyprland con el parámetro '-o' del monitor enfocado
    try:
        for pid_str in os.listdir('/proc'):
            if pid_str.isdigit():
                pid = int(pid_str)
                try:
                    with open(os.path.join('/proc', pid_str, 'cmdline'), 'r') as f:
                        cmdline = f.read().split('\x00')
                    
                    is_dock = any("nwg-dock-hyprland" in arg for arg in cmdline)
                    if is_dock:
                        if monitor_name in cmdline:
                            return pid
                except (IOError, ValueError, PermissionError):
                    continue
    except Exception:
        pass
    return None

def main():
    monitor = get_focused_monitor()
    if not monitor:
        # Fallback: si no podemos determinar el monitor, alternar todos
        subprocess.run(["pkill", "-f", "-35", "nwg-dock-hyprland"], check=False)
        return

    pid = find_dock_process(monitor)
    if pid:
        try:
            # Enviar señal 35 (SIGRTMIN+1) al proceso específico
            os.kill(pid, 35)
        except OSError:
            # Fallback en caso de error
            subprocess.run(["pkill", "-f", "-35", "nwg-dock-hyprland"], check=False)
    else:
        # Si no hay dock corriendo en esta pantalla (ej. conectada recientemente), iniciarlo
        subprocess.Popen([
            "nwg-dock-hyprland",
            "-d",
            "-p", "bottom",
            "-i", "32",
            "-mb", "10",
            "-o", monitor,
            "-m"
        ])
        time.sleep(0.3)
        pid = find_dock_process(monitor)
        if pid:
            try:
                os.kill(pid, 35)
            except OSError:
                pass

if __name__ == "__main__":
    main()
