#!/usr/bin/env python3
import subprocess
import time
import json
import sys

def get_monitors():
    try:
        out = subprocess.check_output(["hyprctl", "monitors", "-j"]).decode("utf-8")
        return json.loads(out)
    except Exception as e:
        return []

def get_outer_edges(monitors):
    result = []
    for m in monitors:
        mx = m["x"]
        mw = m["width"]
        my = m["y"]
        mh = m["height"]
        
        has_left = False
        has_right = False
        
        for other in monitors:
            if other["name"] == m["name"]:
                continue
            ox = other["x"]
            ow = other["width"]
            oy = other["y"]
            oh = other["height"]
            
            vertical_overlap = not (oy + oh <= my or oy >= my + mh)
            
            if vertical_overlap:
                if ox + ow == mx:
                    has_left = True
                if ox == mx + mw:
                    has_right = True
        
        result.append({
            "name": m["name"],
            "x": mx,
            "y": my,
            "width": mw,
            "height": mh,
            "left_outer": not has_left,
            "right_outer": not has_right
        })
    return result

def get_cursor_pos():
    try:
        out = subprocess.check_output(["hyprctl", "cursorpos"]).decode("utf-8").strip()
        parts = out.split(",")
        return int(parts[0].strip()), int(parts[1].strip())
    except Exception:
        return None

def get_active_window():
    try:
        out = subprocess.check_output(["hyprctl", "activewindow", "-j"]).decode("utf-8")
        if not out.strip() or out.strip() == "{}":
            return None
        return json.loads(out)
    except Exception:
        return None

def main():
    # Production quiet run
    monitors = get_monitors()
    outer_monitors = get_outer_edges(monitors)
    
    prev_wx, prev_wy = None, None
    prev_waddr = None
    
    last_switch_time = 0
    cooldown = 1.5
    last_monitor_check = time.time()
    
    while True:
        time.sleep(0.05)
        now = time.time()
        
        if now - last_monitor_check > 10:
            monitors = get_monitors()
            outer_monitors = get_outer_edges(monitors)
            last_monitor_check = now
            
        cursor = get_cursor_pos()
        if not cursor:
            continue
        cx, cy = cursor
        
        # Find current monitor
        current_monitor = None
        for om in outer_monitors:
            if om["x"] <= cx < om["x"] + om["width"] and om["y"] <= cy < om["y"] + om["height"]:
                current_monitor = om
                break
                
        if not current_monitor:
            continue
            
        mx = current_monitor["x"]
        mw = current_monitor["width"]
        
        is_near_left = (cx <= mx + 3)
        is_near_right = (cx >= mx + mw - 4)
        
        if is_near_left or is_near_right:
            win = get_active_window()
            waddr = win.get("address") if win else None
            wpos = win.get("at") if win else None
            
            if wpos:
                wx, wy = wpos[0], wpos[1]
                
                is_at_left = current_monitor["left_outer"] and (cx <= mx + 1)
                is_at_right = current_monitor["right_outer"] and (cx >= mx + mw - 2)
                
                if now - last_switch_time < cooldown:
                    prev_wx, prev_wy = None, None
                    prev_waddr = None
                    continue
                    
                if prev_waddr == waddr and prev_wx is not None:
                    window_moved = (wx != prev_wx) or (wy != prev_wy)
                    
                    if window_moved:
                        if is_at_left:
                            subprocess.run(["hyprctl", "dispatch", "movetoworkspace", "r-1"])
                            new_cx = cx + 120
                            subprocess.run(["hyprctl", "dispatch", "movecursor", f"{new_cx}", f"{cy}"])
                            last_switch_time = time.time()
                        elif is_at_right:
                            subprocess.run(["hyprctl", "dispatch", "movetoworkspace", "r+1"])
                            new_cx = cx - 120
                            subprocess.run(["hyprctl", "dispatch", "movecursor", f"{new_cx}", f"{cy}"])
                            last_switch_time = time.time()
                
                prev_waddr = waddr
                prev_wx, prev_wy = wx, wy
        else:
            prev_wx, prev_wy = None, None
            prev_waddr = None

if __name__ == "__main__":
    main()
