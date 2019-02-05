#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Clarence - programmer's calculator
#
# Copyright (C) 2002-2004 Tomasz Mąka <pasp@ll.pl>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.


import os, sys, getopt
import string, random
from math import *

import pygtk
pygtk.require('2.0')

import gtk, pango

version = "0.4.4"

config = gui = {}
gui["fhelp_window"] = gui["disable_menu"] = 0
disable_menu = 0
labels = ("DEC   =>", "HEX   =>", "OCT   =>", "ASCII =>", "IPv4  =>", "BIN   =>")
entries = ("entry_dec", "entry_hex", "entry_oct", "entry_asc", "entry_ip", "entry_bin")

flist = (
        "|", "Bitwise OR",
        "^", "Bitwise XOR",
        "&", "Bitwise AND",
        "~x", "Bitwise NOT",
        "<<, >>", "Shifts",
        "+", "Addition",
        "-", "Subtraction",
        "*", "Multiplication",
        "/", "Division",
        "%", "Remainder",
        "**", "Exponentiation",
        "+x, -x", "Positive, negative",
        "acircle (r)", "Return the area of circle.",
        "acos (x)", "Return the arc cosine of x.",
        "and", "Boolean AND",
        "ans ()", "Return last result.",
        'asc ("something")', "Return value for last four ASCII chars.",
        "asin (x)", "Return the arc sine of x.",
        "atan (x)", "Return the arc tangent of x.",
        "atan2 (y, x)", "Return atan(y / x).",
        'bin ("10100010110")', "Return value of binary string.",
        "bits (x)", "Return the number of set bits.",
        "ceil (x)", "Return the ceiling of x as a real.",
        "cos (x)", "Return the cosine of x.",
        "cosh (x)", "Return the hyperbolic cosine of x.",
        "e", "The mathematical constant e.",
        "exp (x)", "Return e**x.",
        "fabs (x)", "Return the absolute value of the real x.",
        "floor (x)", "Return the floor of x as a real.",
        "fmod (x, y)", "Return x % y.",
        "hypot (x, y)", "Return the Euclidean distance, sqrt(x*x + y*y).",
        'ip ("192.168.1.22")', "Return value of IPv4 address string.",
        "ldexp (x, i)", "Return x * (2**i).",
        "log (x)", "Return the natural logarithm of x.",
        "log10 (x)", "Return the base-10 logarithm of x.",
        "max (x0, x1, ...)", "Return the biggest element.",
        "min (x0, x1, ...)", "Return the smallest element.",
        "not x", "Boolean NOT",
        "or", "Boolean OR",
        "pcircle (r)", "Return the perimeter of circle.",
        "pi", "The mathematical constant pi.",
        "pow (x, y)", "Return x**y.",
        "rnd ()", "Return the random number in the range [0.0 ... 1.0).",
        "round (x, n)", "Return the floating point value x rounded to n digits after the decimal point.",
        "sasphere (r)", "Return the surface area of sphere.",
        "sin (x)", "Return the sine of x.",
        "sinh (x)", "Return the hyperbolic sine of x.",
        "sqrt (x)", "Return the square root of x.",
        "swap16 (x)", "Alias of swap16l() function.",
        "swap32 (x)", "Swap 16-bit words.",
        "swap16h (x)", "Swap bytes in high 16-bit word.",
        "swap16l (x)", "Swap bytes in 16-bit word.",
        "tan (x)", "Return the tangent of x.",
        "tanh (x)", "Return the hyperbolic tangent of x.",
        "urnd (a, b)", "Return the random number in the range [a ... b].",
        "vcone (r,h)", "Return the volume of cone.",
        "vcylinder (r,h)", "Return the volume of cylinder.",
        "vl2d (x0,y0,x1,y1)", "Return the length of vector (2D).",
        "vl3d (x0,y0,z0,x1,y1,z1)", "Return the length of vector (3D).",
        "vsphere (r)", "Return the volume of sphere."
        )

#------------------------------------------------------------

def window_pos_mode(widget):
    if config["window_placement"] == 0:
        widget.set_position(gtk.WIN_POS_NONE)
    elif config["window_placement"] == 1:
        widget.set_position(gtk.WIN_POS_CENTER)
    elif config["window_placement"] == 2:
        widget.set_position(gtk.WIN_POS_MOUSE)

def main_menu(action, widget):
    if action == 1:
        gui["main_entry"].set_text("")
    elif action == 2:
        gtk.mainquit()
    elif action == 3:
        prefs_window()

def insert_menu(action, widget):
    if action == 1:
        gui["main_entry"].insert_text('bin("")')
        gui["main_entry"].set_position(len(gui["main_entry"].get_text())-2)
    elif action == 2:
        gui["main_entry"].insert_text('asc("")')
        gui["main_entry"].set_position(len(gui["main_entry"].get_text())-2)
    elif action == 3:
        gui["main_entry"].insert_text('ip("")')
        gui["main_entry"].set_position(len(gui["main_entry"].get_text())-2)
    elif action == 4:
        gui["main_entry"].insert_text('ans()')

def select_menu(action, widget):
    if action < 7:
        gui[entries[action-1]].select_region(0, len(gui[entries[action-1]].get_text()))
    else:
        for i in range(5):
            gui[entries[i]].select_region(0, 0)
        gui["main_entry"].grab_focus()

def help_menu(action, widget):
    if action == 1:
        about_window()

#------------------------------------------------------------

def prefs_toggled(widget, option):
    if option == 0:
        if widget.get_active():        # ASCII Only
            config["ascii_only"] = 1
        else:
            config["ascii_only"] = 0
    else:
        if widget.get_active():        # Remember last expression
            config["remember_expression"] = 1
        else:
            config["remember_expression"] = 0

def prefs_selected_1(widget, option):
    config["window_placement"] = option

def prefs_selected_2(widget, option):
    config["binary_separators"] = option

def prefs_window():
    dialog = gtk.Dialog("Preferences", gui["main_window"], 0,
            (gtk.STOCK_CLOSE, gtk.RESPONSE_CLOSE))
    dialog.set_border_width(4)

    dialog.set_size_request(250, 190)
    window_pos_mode(dialog)

    vbox = gtk.VBox(gtk.FALSE, 8)
    dialog.vbox.pack_start(vbox, gtk.TRUE, gtk.FALSE, 0)

    gui["cb_ascii"] = gtk.CheckButton("ASCII only")
    vbox.pack_start(gui["cb_ascii"], gtk.FALSE, gtk.FALSE, 0)
    gui["cb_ascii"].connect("toggled", prefs_toggled, 0)

    gui["cb_rexp"] = gtk.CheckButton("Remember last expression")
    vbox.pack_start(gui["cb_rexp"], gtk.FALSE, gtk.FALSE, 0)
    gui["cb_rexp"].connect("toggled", prefs_toggled, 1)

    hbox = gtk.HBox(gtk.FALSE, 2)
    vbox.pack_start(hbox, gtk.FALSE, gtk.FALSE, 0)

    label = gtk.Label(" Window placement: ")
    hbox.pack_start(label, gtk.FALSE, gtk.FALSE, 0)

    hbox2 = gtk.HBox(gtk.FALSE, 2)
    hbox.pack_start(hbox2, gtk.TRUE, gtk.TRUE, 0)

    menu = gtk.Menu()

    menuitem = gtk.MenuItem("None")
    menuitem.connect("activate", prefs_selected_1, 0)
    menu.append(menuitem)
    menuitem = gtk.MenuItem("Center")
    menuitem.connect("activate", prefs_selected_1, 1)
    menu.append(menuitem)
    menuitem = gtk.MenuItem("Mouse")
    menuitem.connect("activate", prefs_selected_1, 2)
    menu.append(menuitem)

    gui["wp_menu"] = gtk.OptionMenu()
    gui["wp_menu"].set_menu(menu)
    gui["wp_menu"].set_history(config["window_placement"])
    hbox.pack_start(gui["wp_menu"], gtk.FALSE, gtk.FALSE, 0)
    gui["wp_menu"].show()

    hbox = gtk.HBox(gtk.FALSE, 2)
    vbox.pack_start(hbox, gtk.TRUE, gtk.TRUE, 0)

    label = gtk.Label(" Binary separators: ")
    hbox.pack_start(label, gtk.FALSE, gtk.FALSE, 0)

    hbox2 = gtk.HBox(gtk.FALSE, 2)
    hbox.pack_start(hbox2, gtk.TRUE, gtk.TRUE, 0)

    menu = gtk.Menu()

    menuitem = gtk.MenuItem("0")
    menuitem.connect("activate", prefs_selected_2, 0)
    menu.append(menuitem)
    menuitem = gtk.MenuItem("1")
    menuitem.connect("activate", prefs_selected_2, 1)
    menu.append(menuitem)
    menuitem = gtk.MenuItem("3")
    menuitem.connect("activate", prefs_selected_2, 2)
    menu.append(menuitem)
    menuitem = gtk.MenuItem("7")
    menuitem.connect("activate", prefs_selected_2, 3)
    menu.append(menuitem)

    gui["bs_menu"] = gtk.OptionMenu()
    gui["bs_menu"].set_menu(menu)
    gui["bs_menu"].set_history(config["binary_separators"])
    hbox.pack_start(gui["bs_menu"], gtk.FALSE, gtk.FALSE, 0)

    dialog.show_all()

    if config["ascii_only"] == 1:
        gui["cb_ascii"].set_active(gtk.TRUE)
    else:
        gui["cb_ascii"].set_active(gtk.FALSE)

    if config["remember_expression"] == 1:
        gui["cb_rexp"].set_active(gtk.TRUE)
    else:
        gui["cb_rexp"].set_active(gtk.FALSE)

    response = dialog.run()
    dialog.destroy()

    display_binary(int(eval(gui["entry_dec"].get_text())))

#------------------------------------------------------------

def about_window():
    dialog = gtk.Dialog("About", gui["main_window"], 0,
            (gtk.STOCK_CLOSE, gtk.RESPONSE_CLOSE))
    dialog.set_border_width(4)

    dialog.set_size_request(290, 180)
    window_pos_mode(dialog)

    vbox = gtk.VBox(gtk.FALSE, 8)
    dialog.vbox.pack_start(vbox, gtk.TRUE, gtk.FALSE, 0)

    hbox = gtk.HBox(gtk.FALSE, 2)
    hbox.set_border_width(4)
    vbox.pack_start(hbox, gtk.FALSE, gtk.FALSE, 0)

    label = gtk.Label("Clarence (programmer's calculator)")
    hbox.pack_start(label, gtk.TRUE, gtk.FALSE, 0)

    hbox = gtk.HBox(gtk.FALSE, 2)
    hbox.set_border_width(4)
    vbox.pack_start(hbox, gtk.FALSE, gtk.FALSE, 0)

    label = gtk.Label("version " + version)
    hbox.pack_start(label, gtk.TRUE, gtk.FALSE, 0)

    hbox = gtk.HBox(gtk.FALSE, 2)
    hbox.set_border_width(4)
    vbox.pack_start(hbox, gtk.FALSE, gtk.FALSE, 0)

    label = gtk.Label("Written by Tomasz Mąka <pasp@ll.pl>")
    hbox.pack_start(label, gtk.TRUE, gtk.FALSE, 0)

    hbox = gtk.HBox(gtk.FALSE, 2)
    hbox.set_border_width(6)
    vbox.pack_start(hbox, gtk.TRUE, gtk.TRUE, 0)

    entry1 = gtk.Entry()
    entry1.set_text("http://clay.ll.pl/clarence.html")
    entry1.set_editable(gtk.FALSE)
    hbox.pack_start(entry1, gtk.TRUE, gtk.TRUE, 0)

    dialog.show_all()

    response = dialog.run()
    dialog.destroy()

#------------------------------------------------------------

def functions_help_window(*args):
    dialog = gtk.Dialog("Available functions and constants", gui["main_window"], 0,
            (gtk.STOCK_CLOSE, gtk.RESPONSE_CLOSE))
    dialog.set_border_width(4)

    dialog.set_size_request(580, 360)
    window_pos_mode(dialog)

    vbox = gtk.VBox(gtk.FALSE, 8)
    dialog.vbox.pack_start(vbox, gtk.TRUE, gtk.TRUE, 0)

    hbox = gtk.HBox(gtk.FALSE, 2)
    hbox.set_border_width(4)
    vbox.pack_start(hbox, gtk.TRUE, gtk.TRUE, 0)

    scrolled_window = gtk.ScrolledWindow()
    hbox.pack_start(scrolled_window, gtk.TRUE, gtk.TRUE, 0)
    scrolled_window.set_policy(gtk.POLICY_AUTOMATIC, gtk.POLICY_AUTOMATIC)
    scrolled_window.show()

    # [FIXME] clist is depreciated

    clist = gtk.CList(2)
    clist.set_row_height(18)
    clist.set_column_width(0, 180)
    clist.set_column_width(1, 520)
    clist.set_selection_mode(gtk.SELECTION_BROWSE)
    scrolled_window.add(clist)
    clist.show()

    mlist = map(lambda i: "", range(2))

    clist.freeze()
    for i in range(len(flist)/2):
        mlist[0]=flist[i*2]
        mlist[1]=flist[i*2+1]
        clist.append(mlist)
    clist.thaw()

    dialog.show_all()

    response = dialog.run()
    dialog.destroy()

#------------------------------------------------------------

def warning_window(title, message):
    dialog = gtk.Dialog(title, gui["main_window"], 0,
            (gtk.STOCK_OK, gtk.RESPONSE_OK))
    dialog.set_border_width(4)

    dialog.set_size_request(250, 120)
    window_pos_mode(dialog)

    hbox = gtk.HBox(gtk.FALSE, 8)
    hbox.set_border_width(8)
    dialog.vbox.pack_start(hbox, gtk.FALSE, gtk.FALSE, 0)

    stock = gtk.image_new_from_stock(
            gtk.STOCK_DIALOG_WARNING,
            gtk.ICON_SIZE_DIALOG)
    hbox.pack_start(stock, gtk.FALSE, gtk.FALSE, 0)

    label = gtk.Label(message)
    hbox.pack_start(label, )

    dialog.show_all()

    response = dialog.run()
    dialog.destroy()

#------------------------------------------------------------

def create_main_window(*args):

    win = gtk.Window( type=gtk.WINDOW_TOPLEVEL )
    gui["main_window"]=win

    win.set_resizable(gtk.TRUE)
    win.set_title("Clarence " + version)
    win.set_size_request(config["win_width"], config["win_height"])
    win.connect("delete_event", gtk.mainquit)

    window_pos_mode(win)

    vbox1 = gtk.VBox(spacing=5)
    win.add(vbox1)
    vbox1.show()

    ag = gtk.AccelGroup()
    itemf = gtk.ItemFactory(gtk.MenuBar, "<main>", ag)
    gui["main_window"].add_accel_group(ag)
    itemf.create_items([
        ('/_Misc',                        None,                    None,                    0, '<Branch>'),
        ('/_Misc/_Clear',                'Escape',                main_menu,                1, '<StockItem>', gtk.STOCK_CLEAR),
        ('/_Misc/Pre_ferences',            '<control>P',            main_menu,                3, '<StockItem>', gtk.STOCK_PREFERENCES),
        ('/_Misc/sep1',                    None,                    None,                    0, '<Separator>'),
        ('/_Misc/E_xit',                '<control>Q',            main_menu,                2, '<StockItem>', gtk.STOCK_QUIT),
        ('/_Insert',                    None,                    None,                    0, '<Branch>'),
        ('/_Insert/_Bin value',            '<control>comma',        insert_menu,            1, ''),
        ('/_Insert/_ASCII chars',        '<control>period',        insert_menu,            2, ''),
        ('/_Insert/_IPv4 address',        '<control>semicolon',    insert_menu,            3, ''),
        ('/_Insert/sep1',                None,                    None,                    0, '<Separator>'),
        ('/_Insert/_Last result',        '<control>slash',        insert_menu,            4, '<StockItem>', gtk.STOCK_REFRESH),
        ('/_Select',                    None,                    None,                    0, '<Branch>'),
        ('/_Select/_Decimal field',        '<control>1',            select_menu,            1, ''),
        ('/_Select/_Hexadecimal field',    '<control>2',            select_menu,            2, ''),
        ('/_Select/_Octal field',        '<control>3',            select_menu,            3, ''),
        ('/_Select/_ASCII field',        '<control>4',            select_menu,            4, ''),
        ('/_Select/_IPv4 field',        '<control>5',            select_menu,            5, ''),
        ('/_Select/_Binary field',        '<control>6',            select_menu,            6, ''),
        ('/_Select/sep1',                None,                    None,                    0, '<Separator>'),
        ('/_Select/_Clear fields',        '<control>0',            select_menu,            6, '<StockItem>', gtk.STOCK_CLEAR),
        ('/_Help',                        None,                    None,                    0, '<LastBranch>'),
        ('/_Help/Functions',            'F1',                    functions_help_window,    1, '<StockItem>', gtk.STOCK_HELP),
        ('/_Help/_About',                None,                    help_menu,                1, '<StockItem>', gtk.STOCK_HOME)
    ])
    menubar = itemf.get_widget('<main>')
    if (gui["disable_menu"] == 0):
        vbox1.pack_start(menubar, expand=gtk.FALSE)
        menubar.show()

    vbox2 = gtk.VBox(spacing=5)
    vbox1.pack_start (vbox2, expand=gtk.TRUE);
    vbox2.show()

    entry = gtk.Entry()
    gui["main_entry"] = entry
    vbox2.pack_start(entry, expand=gtk.FALSE)
    vbox2.set_border_width(4)
    entry.modify_font(gui["fixed_font"])
    if (config["remember_expression"] == 1):
        entry.set_text(config["last_expression"])
    entry.connect("key_press_event", key_function)
    entry.grab_focus()
    gui["main_entry"].show()

    frame = gtk.Frame()
    vbox2.pack_start(frame)
    frame.show()

    vbox3 = gtk.VBox()
    frame.add(vbox3)
    vbox3.show()

    table = gtk.Table(2, 6, gtk.FALSE)
    table.set_row_spacings(5)
    table.set_col_spacings(5)
    table.set_border_width(10)
    vbox3.pack_start(table)
    table.show()

    for y in range(6):
        label = gtk.Label(labels[y])
        label.modify_font(gui["fixed_font"])
        label.show()
        table.attach(label, 0,1, y,y+1)
        entry = gtk.Entry()
        gui[entries[y]] = entry
        entry.set_editable(gtk.FALSE)
        entry.set_size_request(300, -1)
        entry.modify_font(gui["fixed_font"])
        entry.show()
        table.attach(entry, 1,2, y,y+1)

    gui["main_window"].show()

    if (config["remember_expression"] == 1):
        result(config["last_expression"])
    else:
        result(0)

#------------------------------------------------------------

def getachr(value):
    fld = 255
    if (config["ascii_only"] == 1):
        fld = 127
    if (value>=32) and (value<=fld):
        return value
    else:
        return "."

#------------------------------------------------------------
# functions

def swap16l(x):
    return ((x & 0xff00) >> 8) + ((x & 0xff) << 8) + (x & 0xffff0000)

def swap16h(x):
    return ((x & 0xff000000) >> 8) + ((x & 0x00ff0000) << 8) + (x & 0xffff)

def swap16(x):
    return swap16l(x)

def swap32(x):
    return ((x & 0xffff0000) >> 16) + ((x & 0xffff) << 16)

def vl2d(x0,y0,x1,y1):
    return sqrt((x1-x0)**2 + (y1-y0)**2)

def vl3d(x0,y0,z0,x1,y1,z1):
    return sqrt((x1-x0)**2 + (y1-y0)**2 + (z1-z0)**2)

def acircle(r):
    return pi*r*r

def pcircle(r):
    return 2.0*pi*r

def vsphere(r):
    return (4.0/3.0)*pi*r*r*r

def sasphere(r):
    return 4.0*pi*r*r

def vcone(r,h):
    return (1.0/3.0)*pi*r*r*h

def vcylinder(r,h):
    return pi*r*r*h

def rnd():
    return random.random()

def urnd(a, b):
    return round(a+(b-a)*random.random())        #uniform()

#------------------------------------------------------------

def bits(value):
    result=0
    for i in range(32):
        k=(value >> i) & 1
        if (k):
            result=result+1
    return result

#------------------------------------------------------------

def bin(value):
    result=0
    for i in range(len(value)):
        if (value[i]!="0" and value[i]!="1"):
            return 0
    for i in range(len(value)):
        if (i>=32):
            return 0
        result=result+((ord(value[len(value)-1-i])-ord("0")) * 1<<i)
    return result

#------------------------------------------------------------

def asc(value):
    result=0
    for i in range(len(value)):
        if (i<4):
            result=result+(ord(value[len(value)-1-i]) * 256**i)
    return result

#------------------------------------------------------------

def ans():
    return eval(gui["entry_dec"].get_text())

#------------------------------------------------------------

def display_binary(value):
    r_bin=""
    mode = config["binary_separators"]
    for i in range(32):
        k = 31 - i
        chrr=chr(ord("0")+((value>>k) & 1))
        r_bin=r_bin+chrr
        if (mode and (k > 0) and (k % (16/(2**(mode-1)))==0)):
            r_bin=r_bin+"."
    gui["entry_bin"].set_text(r_bin)

#------------------------------------------------------------

def display_ip(value):
    r_ip = str((value & 0xff000000)>>24)
    r_ip += "."
    r_ip += str((value & 0xff0000)>>16)
    r_ip += "."
    r_ip += str((value & 0xff00)>>8)
    r_ip += "."
    r_ip += str(value & 0xff)
    gui["entry_ip"].set_text(r_ip)

def ip(ipn):
    result = 0;

    if(string.count(ipn, ".") == 3):
        fields = string.splitfields(ipn, ".")
        nb  = (long(string.atoi(fields[0]) & 0xff) << 24)
        nb += ((string.atoi(fields[1]) & 0xff) << 16)
        nb += ((string.atoi(fields[2]) & 0xff) << 8)
        nb += (string.atoi(fields[3]) & 0xff)
        result = int(nb)

    return result

#------------------------------------------------------------

def result(value):
    if (value):
        try:
            resl=eval(value)
            resli=int(resl)
        except NameError:
            warning_window("Warning", "Function not found!")
            return 0
        except SyntaxError:
            warning_window("Warning", "Wrong syntax!")
            return 0
        except TypeError:
            warning_window("Warning", "Wrong syntax!")
            return 0
        except ZeroDivisionError:
            warning_window("Warning", "Division by zero!")
            return 0
        except OverflowError:
            warning_window("Warning", "Overflow detected!")
            return 0
        except ValueError:
            warning_window("Warning", "Value error!")
            return 0
        except FutureWarning:
            return 0

    else:
        resl=0
        resli=0
    r_dec = str(resl)
    gui["entry_dec"].set_text(r_dec)
    r_hex = string.strip(str(hex(resli)), "L")
    gui["entry_hex"].set_text(r_hex)
    r_oct = string.strip(str(oct(resli)), "L")
    gui["entry_oct"].set_text(r_oct)
    r_asc="%c%c%c%c" % (getachr((resli>>24) & 255),
    getachr((resli>>16) & 255),
    getachr((resli>>8) & 255), getachr(resli & 255))
    gui["entry_asc"].set_text(r_asc)
    display_ip(resli)
    display_binary(resli)

#------------------------------------------------------------

def key_function(entry, event):
    if event.keyval == gtk.gdk.keyval_from_name('Return'):
        entry.set_text(entry.get_text())
        result(entry.get_text())

#------------------------------------------------------------

def pcalc_get_cfg_dir():
    if os.name == 'posix':
        cfg_dir = os.environ["HOME"]
    elif os.name == 'nt':
        cfg_dir = os.environ["HOMEDRIVE"] + os.environ["HOMEPATH"]
    else:
        sys.exit('Sorry, unknown environment variable for user home on %s OS!' % os.name)
    cfg_dir = os.path.join(cfg_dir, ".clay")
    return cfg_dir

#------------------------------------------------------------

def pcalc_get_cfg_file():
    return os.path.join(pcalc_get_cfg_dir(), "clarence")

#------------------------------------------------------------

def pcalc_check_config():
		cfg_dir = pcalc_get_cfg_dir()
		if not os.access(cfg_dir, os.F_OK):
			os.mkdir(cfg_dir)
		cfg_file = pcalc_get_cfg_file()
		if not os.access(cfg_file, os.F_OK):
		    f = open(cfg_file, "w")
		    f.write("window_placement=1\n")                # 0 - none,  1 - center, 2 - mouse
		    f.write("ascii_only=0\n")                    # 0 - eascii codes (32-255), 1 - ascii (32-127)

		    if os.name == 'posix':
		        f.write("fixed_font=monospace 10\n")      # name of fixed font
		        f.write("win_width=420\n")
		        f.write("win_height=250\n")
		    elif os.name == 'nt':
		        f.write("fixed_font=fixedsys\n")        # name of fixed font
		        f.write("win_width=500\n")
		        f.write("win_height=280\n")

		    f.write("remember_expression=1\n")            # 0 - no,  1 - yes
		    f.write("binary_separators=3\n")            # 0, 1, 3, 5, 7
		    f.write("last_expression=\n")                # last expression
		    f.flush()
		    f.close()

#------------------------------------------------------------

def pcalc_read_config():
    f_lines = open(pcalc_get_cfg_file(), 'r').readlines()
    for line in f_lines:
        fields = string.split(line, '=')
        if (fields[0] == "win_width"):
            config["win_width"] = string.atoi(fields[1])
        if (fields[0] == "win_height"):
            config["win_height"] = string.atoi(fields[1])
        if (fields[0] == "window_placement"):
            config["window_placement"] = string.atoi(fields[1])
        if (fields[0] == "ascii_only"):
            config["ascii_only"] = string.atoi(fields[1])
        if (fields[0] == "fixed_font"):
            config["ffont"] = string.strip(fields[1])
        if (fields[0] == "remember_expression"):
            config["remember_expression"] = string.atoi(fields[1])
        if (fields[0] == "binary_separators"):
            config["binary_separators"] = string.atoi(fields[1])
        if (fields[0] == "last_expression"):
            config["last_expression"] = string.strip(fields[1])

#------------------------------------------------------------

def pcalc_write_config():
    if (config["remember_expression"] == 1):
        config["last_expression"]=string.replace(gui["main_entry"].get_text(), "ans()", "0")
    f = open(pcalc_get_cfg_file(), "w")
    f.write("win_width=%d\n" % config["win_width"])
    f.write("win_height=%d\n" % config["win_height"])
    f.write("window_placement=%d\n" % config["window_placement"])
    f.write("ascii_only=%d\n" % config["ascii_only"])
    f.write("fixed_font=%s\n" % config["ffont"])
    f.write("remember_expression=%d\n" % config["remember_expression"])
    f.write("binary_separators=%d\n" % config["binary_separators"])
    f.write("last_expression=%s\n" % config["last_expression"])
    f.flush()
    f.close()

#------------------------------------------------------------

def usage():
    sys.stderr.write("usage: clarence [-hvm] [--help] [--version] [--disable-menu]\n")
    sys.exit(2)

def main():

    try:
        opts, args = getopt.getopt(sys.argv[1:], "vhm", ["version", "help", "disable-menu"])
    except getopt.GetoptError:
        usage()

    for o, a in opts:
        if o in ("-v", "--version"):
            print(version)
            sys.exit()
        if o in ("-h", "--help"):
            usage()
        if o in ("-m", "--disable-menu"):
            gui["disable_menu"] = 1

    pcalc_check_config()
    pcalc_read_config()
    gui["fixed_font"] = pango.FontDescription(config["ffont"])
    create_main_window()
    gtk.mainloop()
    pcalc_write_config()

if __name__ == '__main__':
    main()

