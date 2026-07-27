// ============================================================================
//  Sauna Monitor Enclosure  --  parametric OpenSCAD model
// ----------------------------------------------------------------------------
//  Houses an ESP32 dev board + a MAX31855 K-type thermocouple amplifier for
//  the Wi-Fi Sauna Temperature Monitor project (see repo README).
//
//  IMPORTANT SAFETY / PLACEMENT NOTE:
//    This box is for the *EXTERIOR* mount only. It bolts to a cool, shaded
//    outside wall of the sauna building. It must NEVER be placed inside the
//    hot sauna room -- the ESP32 tops out around 85 C. Only the thermocouple
//    probe and its high-temp lead go into the sauna. This enclosure is
//    designed for outdoor weather + humidity resistance (IP65-ish intent):
//    a gasket groove + screw-down lid, NOT a perfect hermetic seal.
//
//  Standard OpenSCAD only -- no external libraries (no BOSL2 etc.).
//  Helper modules for rounded boxes are defined at the bottom.
//
//  Coordinate convention: geometry is centered on X and Y; Z=0 is the outside
//  bottom of the base. All units are millimetres.
// ============================================================================


// ============================================================================
//  PART SELECTION
// ============================================================================
// "base" = box body only, "lid" = lid only,
// "both" = both laid out side by side for preview (default).
part = "both";


// ============================================================================
//  KEY PARAMETERS  --  edit these to fit your hardware
// ============================================================================

// ---- Render quality -------------------------------------------------------
$fn = 48;              // facets for cylinders/arcs (bump to 96 for final STL)

// ---- Wall / shell ---------------------------------------------------------
wall          = 3.0;   // side wall thickness
floor_th      = 3.0;   // base floor thickness
lid_th        = 3.0;   // lid plate thickness
corner_r      = 5.0;   // external corner radius (rounded box)

// ---- Internal cavity (usable space for the boards) ------------------------
// These set the *interior* clear dimensions. Increase if you add more wiring
// room, a bigger desiccant pack, etc.
inner_l       = 90.0;  // interior length (X)  -- long axis
inner_w       = 60.0;  // interior width  (Y)
inner_h       = 30.0;  // interior height (Z), floor top -> lid mating face

// ---- Lid / base fit -------------------------------------------------------
lip_h         = 4.0;   // depth of the locating lip on the lid
lip_clear     = 0.35;  // clearance so the lip slides into the opening
lid_gap       = 12.0;  // gap between base and lid in the "both" preview layout

// ---- Gasket groove (in the lid mating face) -------------------------------
// A rectangular channel cut into the underside of the lid, sitting over the
// centreline of the base wall. Fill with silicone cord (see README).
gasket_groove_w = 2.4; // groove width  (for ~2 mm silicone cord)
gasket_groove_d = 1.6; // groove depth

// ---- Lid corner screws (M3, captive in base corner bosses) ----------------
lid_screw_d        = 3.0;   // nominal M3
lid_screw_clear_d  = 3.4;   // clearance hole in the lid
lid_screw_head_d   = 6.0;   // counterbore for the screw head in the lid
lid_screw_head_h   = 3.0;   // counterbore depth
lid_boss_od        = 8.0;   // corner boss outer diameter in the base
lid_boss_pilot_d   = 2.5;   // pilot hole for M3 self-tapping into the boss
lid_boss_inset     = 6.0;   // boss centre inset from the outer corner
                            // (kept < wall+corner_r so the boss overlaps the
                            //  corner wall for a clean, well-fused union)

// ---- Board mounting standoffs (self-tapping bosses) -----------------------
// Set to M2.5 (pilot ~2.1) or M3 (pilot ~2.5) self-tappers.
standoff_h         = 4.0;   // how far the boards sit above the floor
standoff_od        = 6.0;   // boss outer diameter
standoff_pilot_d   = 2.5;   // pilot hole diameter (M3 self-tap default)

// ESP32 dev board (generic devkit). Mounting-hole spacing between the 4 holes.
// Many DevKitC clones are ~55 x 28 mm; adjust the hole spacing to YOUR board.
esp_hole_sx        = 45.0;  // hole spacing along X
esp_hole_sy        = 22.0;  // hole spacing along Y
esp_center_x       = -17.0; // where the ESP32 sits inside the cavity (X)
esp_center_y       = 0.0;   // (Y)

// MAX31855 breakout (~20 x 25 mm). Adafruit-style board hole spacing.
max_hole_sx        = 15.0;  // hole spacing along X
max_hole_sy        = 20.0;  // hole spacing along Y
max_center_x       = 32.0;  // where the MAX31855 sits inside the cavity (X)
max_center_y       = 0.0;   // (Y)

// ---- Cable glands (IP68) on one side wall ---------------------------------
// PG7 ~ 12.5 mm, PG9 ~ 15.2 mm mounting-hole diameter. Pick per gland.
pg7_hole_d         = 12.5;  // convenience constant
pg9_hole_d         = 15.2;  // convenience constant
gland_tc_d         = pg7_hole_d;  // thermocouple lead gland hole
gland_pwr_d        = pg9_hole_d;  // 5V USB power gland hole
gland_z            = 14.0;  // gland centre height above the floor top
gland_tc_x         = -22.0; // X position of thermocouple gland on the wall
gland_pwr_x        =  22.0; // X position of power gland on the wall

// ---- Optional Gore-style vent plug ----------------------------------------
// Equalises pressure / lets humidity out instead of a loose desiccant pack.
enable_vent        = true;  // set false to rely on a desiccant pack instead
vent_hole_d        = 12.0;  // M12 vent-plug hole (~12 mm)
vent_z             = 16.0;  // vent centre height above the floor top
vent_x             = 0.0;   // vent X position on the (opposite) wall

// ---- External wall-mount ears / flanges -----------------------------------
ear_w              = 16.0;  // ear length along X
ear_depth          = 12.0;  // how far the ear sticks out from the wall (Y)
ear_th             = 4.0;   // ear thickness (Z)
ear_screw_d        = 5.0;   // wall-fixing screw clearance hole in the ear
ear_z              = 0.0;   // ears flush with the base bottom


// ============================================================================
//  DERIVED DIMENSIONS  (do not usually need editing)
// ============================================================================
OL  = inner_l + 2*wall;          // outer length (X)
OW  = inner_w + 2*wall;          // outer width  (Y)
OH  = floor_th + inner_h;        // outer height of the base (Z)
inner_r = max(corner_r - wall, 0.5);  // interior corner radius

eps = 0.01;                      // tiny overlap to avoid coincident faces
sink = 0.6;                      // how far internal posts sink into the floor
                                 // (ensures a clean manifold union, no coincident faces)


// ============================================================================
//  TOP-LEVEL RENDER
// ============================================================================
if (part == "base") {
    base();
} else if (part == "lid") {
    lid();
} else {
    // "both" -- lay them side by side for preview / plating.
    base();
    translate([OL/2 + OW/2 + lid_gap, 0, 0])
        rotate([0, 0, 90])          // rotate so both fit compactly
            lid();
}


// ============================================================================
//  BASE (box body)
// ============================================================================
// NOTE ON STRUCTURE: internal features (bosses, standoffs) must be added
// AFTER the cavity is subtracted -- otherwise the cavity cut would erase them.
// So we union three independently-differenced groups rather than doing one
// big difference().
module base() {
    union() {
        // 1) Hollow shell with the wall penetrations.
        difference() {
            shell();
            cavity();                  // hollow interior
            gland_holes();             // two cable-gland penetrations
            if (enable_vent) vent_hole();
        }
        // 2) External wall-mount ears (live outside the cavity) with their holes.
        difference() {
            mount_ears();
            ear_holes();
        }
        // 3) Internal bosses + standoffs (live inside the cavity) with pilots.
        difference() {
            union() {
                lid_bosses();          // corner bosses that capture the lid screws
                board_standoffs();     // ESP32 + MAX31855 mounting posts
            }
            lid_boss_pilots();         // pilot holes down the lid bosses
            board_standoff_pilots();   // pilot holes in the board standoffs
        }
    }
}

// Solid outer shell of the base (before hollowing).
module shell() {
    rbox(OL, OW, OH, corner_r);
}

// Interior cavity removed from the shell (open at the top).
module cavity() {
    translate([0, 0, floor_th])
        rbox(inner_l, inner_w, inner_h + eps + lip_h, inner_r);
}

// Four corner bosses inside the base that the lid screws thread into.
module lid_bosses() {
    for (sx = [-1, 1], sy = [-1, 1])
        translate([sx*(OL/2 - lid_boss_inset),
                   sy*(OW/2 - lid_boss_inset),
                   floor_th - sink])
            cylinder(h = inner_h + sink, d = lid_boss_od);
}

// Pilot holes drilled down through the corner bosses for M3 self-tappers.
module lid_boss_pilots() {
    for (sx = [-1, 1], sy = [-1, 1])
        translate([sx*(OL/2 - lid_boss_inset),
                   sy*(OW/2 - lid_boss_inset),
                   floor_th + inner_h - 14])
            cylinder(h = 14 + eps, d = lid_boss_pilot_d);
}

// Cable-gland holes through the front wall (y = -OW/2), axis along Y.
module gland_holes() {
    // thermocouple lead gland
    translate([gland_tc_x, -OW/2 - eps, floor_th + gland_z])
        rotate([-90, 0, 0])
            cylinder(h = wall + 2*eps, d = gland_tc_d);
    // 5V USB power gland
    translate([gland_pwr_x, -OW/2 - eps, floor_th + gland_z])
        rotate([-90, 0, 0])
            cylinder(h = wall + 2*eps, d = gland_pwr_d);
}

// Optional Gore vent-plug hole in the back wall (y = +OW/2).
module vent_hole() {
    translate([vent_x, OW/2 + eps, floor_th + vent_z])
        rotate([90, 0, 0])
            cylinder(h = wall + 2*eps, d = vent_hole_d);
}

// External wall-mount ears on the left and right walls, at the base bottom.
// The ear penetrates the shell wall by `ear_overlap` so the union is a clean
// 2-manifold solid (a tab merely tangent to the wall produces non-manifold edges).
ear_overlap = 3.0;
module mount_ears() {
    for (sx = [-1, 1])
        translate([sx*(OL/2 + ear_depth/2 - ear_overlap/2), 0, ear_z + ear_th/2])
            cube([ear_depth + ear_overlap, ear_w, ear_th], center = true);
}

// Wall-fixing screw holes in the ears.
module ear_holes() {
    for (sx = [-1, 1])
        translate([sx*(OL/2 + ear_depth*0.6), 0, ear_z - eps])
            cylinder(h = ear_th + 2*eps, d = ear_screw_d);
}

// Board mounting standoffs (bosses) for the ESP32 and the MAX31855.
module board_standoffs() {
    four_standoffs(esp_center_x, esp_center_y, esp_hole_sx, esp_hole_sy);
    four_standoffs(max_center_x, max_center_y, max_hole_sx, max_hole_sy);
}

// Pilot holes in the board standoffs (self-tapping screws).
module board_standoff_pilots() {
    four_standoff_pilots(esp_center_x, esp_center_y, esp_hole_sx, esp_hole_sy);
    four_standoff_pilots(max_center_x, max_center_y, max_hole_sx, max_hole_sy);
}

// Helper: four standoff posts arranged on a rectangle of the given hole spacing.
module four_standoffs(cx, cy, sx, sy) {
    for (dx = [-1, 1], dy = [-1, 1])
        translate([cx + dx*sx/2, cy + dy*sy/2, floor_th - sink])
            cylinder(h = standoff_h + sink, d = standoff_od);
}

module four_standoff_pilots(cx, cy, sx, sy) {
    for (dx = [-1, 1], dy = [-1, 1])
        translate([cx + dx*sx/2, cy + dy*sy/2, floor_th - eps])
            cylinder(h = standoff_h + eps, d = standoff_pilot_d);
}


// ============================================================================
//  LID
// ============================================================================
// Built mating-face-DOWN: the flat outer face is at the top (+Z), the gasket
// groove and locating lip face down (-Z at z=0).
module lid() {
    difference() {
        union() {
            // main plate
            translate([0, 0, 0])
                rbox(OL, OW, lid_th, corner_r);
            // locating lip that drops into the base opening
            translate([0, 0, -lip_h])
                rbox(inner_l - 2*lip_clear,
                     inner_w - 2*lip_clear,
                     lip_h + eps,
                     inner_r);
        }
        // gasket groove in the mating face, over the wall centreline
        gasket_groove();
        // clearance for the base corner bosses so the lid seats flat
        lid_boss_clearance();
        // corner screw holes + counterbores
        lid_screw_holes();
    }
}

// Rectangular gasket channel cut into the lid mating face (underside).
module gasket_groove() {
    // centreline of the base wall (mean of outer and inner perimeter)
    cl = OL - wall;   // groove path length (X), centred
    cw = OW - wall;   // groove path width  (Y), centred
    translate([0, 0, -eps])
        linear_extrude(height = gasket_groove_d + eps)
            difference() {
                rrect(cl + gasket_groove_w, cw + gasket_groove_w, corner_r);
                rrect(cl - gasket_groove_w, cw - gasket_groove_w, inner_r);
            }
}

// Pockets so the lid clears the base's corner bosses.
module lid_boss_clearance() {
    for (sx = [-1, 1], sy = [-1, 1])
        translate([sx*(OL/2 - lid_boss_inset),
                   sy*(OW/2 - lid_boss_inset),
                   -lip_h - eps])
            cylinder(h = lip_h + eps, d = lid_boss_od + 0.6);
}

// M3 clearance holes through the lid with a counterbore for the screw head.
module lid_screw_holes() {
    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([sx*(OL/2 - lid_boss_inset),
                   sy*(OW/2 - lid_boss_inset), 0]) {
            // through clearance hole
            translate([0, 0, -lip_h - eps])
                cylinder(h = lid_th + lip_h + 2*eps, d = lid_screw_clear_d);
            // counterbore on the top (outer) face
            translate([0, 0, lid_th - lid_screw_head_h])
                cylinder(h = lid_screw_head_h + eps, d = lid_screw_head_d);
        }
    }
}


// ============================================================================
//  HELPER MODULES  (rounded box / rounded rectangle, no external libraries)
// ============================================================================

// 2D rounded rectangle, centred on the origin.
module rrect(l, w, r) {
    rr = min(r, l/2, w/2);
    hull()
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(l/2 - rr), sy*(w/2 - rr)])
                circle(r = rr);
}

// 3D rounded box, centred on X/Y, extruded up from z=0.
module rbox(l, w, h, r) {
    linear_extrude(height = h)
        rrect(l, w, r);
}
