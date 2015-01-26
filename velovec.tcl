proc velo {key args} {
  # vmd_frame (self adjustable)
  if { $key == "on" || $key == "enable"} {
    puts "Velocity vector drawing enable"
    enabletrace

  # vmd_frame (self adjustable)
  } elseif { $key == "off" || $key == "disable" || $key == "stop" } {
    puts "Velocity vector drawing disable"
    disabletrace

  # energy recalc 
  } elseif { $key == "energy" || $key == "e" } {
    global energy
    if { $args == "off" } {
      set energy "off"
      puts "Energy recalc from velocity off"
      global textUnit
      set textUnit "A/ps"
    } elseif { $args == "on" } {
      set energy "on"
      global textUnit
      set textUnit "eV"
      puts "Energy recalc from velocity on !!! Current assumption v\[A/ps\]"
      global textUnit
      set textUnit "eV"
    }

  # selected (selection)
  } elseif { $key == "sel" || $key == "selection" } {
    global selected
    set selected $args
    puts "Changing selection to: $args"

  # value fork 
  } elseif { $key == "fork" || $key == "fromto" } {
    global fork
    set fork $args
    puts "Value fork set to: $args"

  # vecStyle (style)   vecScale (scale)   vecColor (color)
  } elseif { $key == "vector" || $key == "vec" } {
    global vecStyle
    global vecScale
    global vecColor

    set len [llength $args]

    if { $len == 0 } {
      unknowSubKey $key "none"
    }
    
    set i 0
    while { $i < $len } {
      set subKey [lindex $args $i]
      if { $subKey == "style" } { 
        incr i
        set vecStyle [lindex $args $i]
        puts "Vector style: $vecStyle"
      } elseif { $subKey == "scale" } {
        incr i
        set vecScale [lindex $args $i]
        puts "Vector scale: $vecScale"
      } elseif { $subKey == "color" } {
        incr i
        set vecColor [lindex $args $i]
        puts "Vector coloring: $vecColor"
      } else {
        unknowSubKey $key $subKey
        return
      }
      incr i
    }

  # textShift (shift)  textSize (size)  textColor (color)   textStyle (style)
  # affix/unit (unit)
  } elseif { $key == "txt" || $key == "text"} {
    global textShift
    global textSize
    global textColor
    global textStyle
    global textPlace

    set len [llength $args]

    if { $len == 0 } {
      unknowSubKey $key "none"
      return
    }
    
    set i 0
    while { $i < $len } {
      set subKey [lindex $args $i]
      if { $subKey == "off" || $subKey == "stop" } {
        puts "Text display off" 
        global textStyle
        set textStyle "off"
        return

      } elseif { $subKey == "shift" } {
        incr i
        set textShift [lindex $args $i]
        puts "Text shift from atom: $textShift"
        graphics top text $textShift "test TXT"
      } elseif { $subKey == "size" } {
        incr i
        set textSize [lindex $args $i]
        puts "Text size: $textSize"
      } elseif { $subKey == "color" } {
        incr i
        set textColor [lindex $args $i]
        puts "Text color: $textColor"
      
      } elseif { $subKey == "style" } {
        incr i
        set textStyle [lindex $args $i]
        puts "Text style: $textStyle"
      } elseif { $subKey == "unit" } {
        incr i
        set textUnit [lindex $args $i]
        puts "Text units: $textUnit"
      } elseif { $subKey == "place" || $subKey == "onvec" || $subKey == "vec" } {
        incr i
        set textPlace [lindex $args $i]
      } else {
        unknowSubKey $key $subKey
        return
      }
      incr i
    }
  } else {
    unknowKey $key
    return
  }
}

proc unknowKey { key } {
  puts ": $key : is unknow option" 
}

proc unknowSubKey { key subKey } {
  puts "Option : $key : dont have sub option : $subKey :"
}

#---------------------------------------------------------
# Internal control methods

# DEFAULT
proc setDefault { } { 
  # vecStyle (style)   vecScale (scale)   vecColor (color)
  # textShift (shift)  textSize (size)  textColor (color)   textStyle (style)
  
  # Vector -------
  global vecStyle 
  set vecStyle "line"
  global vecScale 
  set vecScale 1.0
  global vecColor
  set vecColor "red"
  global vecConeRad
  set vecConeRad 1.0
  global vecCylRad
  set vecCylRad 0.7

  # Text ---------
  global textShift
  set textShift {0.0 0.0 0.0}
  global textSize
  global textColor
  set textColor "green"
  global textStyle
  set textStyle "off"
  global textUnit
  set textUnit "eV"
  global textPlace
  set textPlace 0.8

  # selection
  global selected
  set selected "all"
  # value fork
  global fork
  set fork {0.0 1000000000000.0}
  # energy recalc
  global energy
  set energy "off"
}

proc enabletrace {} { 
  global vmd_frame; 
  trace variable vmd_frame([molinfo top]) w drawcounter 
  setDefault
} 

proc disabletrace {} { 
  global vmd_frame; 
  trace vdelete vmd_frame([molinfo top]) w drawcounter 
} 

#--------------------------------------------------------
# Drawing



proc vectorText {x_ v_ vs_} {
  global textColor
  global textUnit
  global textShift
  global vecColor
  global vecScale


  set vScaled [vecscale $vecScale $v_]
  set mid [vecadd $x_ [vecscale 0.8 $vScaled]]
  set end [vecadd $x_ $vScaled]

  draw color $vecColor
  graphics top  cylinder $x_ $mid radius 0.8
  graphics top  cone $mid $end radius 1.2

  # !!!!!!!!!! vs nie przeskalowany !!!!!
  draw color $textColor
  draw text [vecadd $mid $textShift] "[format "%.2f" $vs_] $textUnit" thickness 2
 
}

proc drawText {x_ v_ vs_} {
  global textColor
  global textShift
  global textStyle
  global textUnit
  global textPlace

  set setText [vecadd [vecadd $x_ [vecscale 0.8 $v_]] $textShift]
 
  draw color $textColor
  draw text $setText "[format "%.2f" $vs_] $textUnit" thickness 2
  #expr {double(round(100*[veclength $v_]))/100}
}

proc drawVector {x_ v_} {
  global vecColor
  global vecScale
  global vecConeRad
  global vecCylRad

  set vScaled [vecscale $vecScale $v_]
  set mid [vecadd $x_ [vecscale 0.8 $vScaled]]
  set end [vecadd $x_ $vScaled]

  draw color $vecColor
  graphics top  cylinder $x_ $mid radius $vecConeRad
  graphics top  cone $mid $end radius $vecCylRad
}

proc drawSimpleVector {x_ v_} {
  draw color "red"
  global vecScale
  set v_ [vecscale $vecScale $v_]
  set mid [vecadd $x_ [vecscale 0.8 $v_]]
  set end [vecadd $x_ $v_]
  graphics top  cylinder $x_ $mid radius 0.8
  graphics top  cone $mid $end radius 1.0
}

proc drawElements {} {

  # main variable aqq
  global vmd_frame
  set frm $vmd_frame([molinfo top])

  global selected
  set sel [atomselect top $selected frame $frm]

  set x [$sel get {x y z}]
  set len [llength $x]

  # recalc/rescale
  global energy
  if { $energy == "on" } {
    puts "recalcing energy"
    set vusc [$sel get {vx vy vz}]
    set mass [$sel get {mass}]
    set i 0
    while { $i < $len } {
      set vs [lindex $vusc $i]
      set vls [ expr { 0.00005186 * [ vecdot $vs $vs ] * [lindex $mass $i] } ]

      lappend vl $vls
      # 5.186 * 10^-5 = 0.00005186
      lappend v [ vecscale $vs [ expr { $vls / [ veclength $vs ] } ] ]
      incr i
    }
  } else {
    set v [$sel get {vx vy vz}]
    set i 0
    while { $i < $len } {
      lappend vl [veclength [lindex $v $i]]
      incr i
    }
  }
 
  # Tutaj che vl x 

  # Drawing 
  global fork
  global vecStyle
  set i 0
  # --- Draw vector ---
  if { $vecStyle != "off" } {
    while { $i < $len } {
      set vls [lindex $vl $i]
      if { $vls > [lindex $fork 0] && $vls < [lindex $fork 1] } {
        drawSimpleVector [lindex $x $i] [lindex $v $i]
        #drawVector [lindex $x $i] [lindex $v $i]
      }
      incr i
    }
  }

  # --- Draw text ---
  global textStyle
  set i 0
  if { $textStyle != "off" } {
    while { $i < $len } {
      set vls [lindex $vl $i]
      if { $vls > [lindex $fork 0] && $vls < [lindex $fork 1] } {
        drawText [lindex $x $i] [lindex $v $i] $vls
      }
      incr i
    }
  }
}

# --- main ---
proc drawcounter { name element op } { 
  global vmd_frame; 
  draw delete all 
  drawElements
} 

velo on


# -------------------
# -- junk code ------
proc arrowVector {x_ v_} {
  global vecColor
  draw color $vecColor
  global vecScale
  set vScaled [vecscale $vecScale $v_]
  set mid [vecadd $x_ [vecscale 0.8 $vScaled]]
  set end [vecadd $x_ $vScaled]
  graphics top  cylinder $x_ $mid radius 0.8
  graphics top  cone $mid $end radius 1.2
}

proc liaeVector {x_ v_} {
  global vecColor;
  draw color $vecColor
  global vecScale
  graphics top line $x_ [vecadd $x_  [vecscale $vecScale $v_] ]
}
