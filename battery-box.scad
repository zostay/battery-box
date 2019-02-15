type="cylinder"; // "bundle" OR "cylinder" OR "block"

bundle_width_count=4;
bundle_length_count=1;

battery_diameter=14;

battery_width=26;
battery_length=17;

battery_bundle_spacing=0;
battery_clearance=0.3;

battery_diameter_w_clearance=battery_diameter+battery_clearance;

battery_width_w_clearance=battery_width+battery_clearance;
battery_length_w_clearance=battery_length+battery_clearance;

bundle_width=bundle_width_count*battery_diameter+battery_bundle_spacing*(bundle_width_count-1)+battery_clearance*2;
bundle_length=bundle_length_count*battery_diameter+battery_bundle_spacing*(bundle_length_count-1)+battery_clearance*2;

battbox_count_wide=1;
battbox_count_long=4;

battbox_spacing=1;
battbox_height=30;

joint_height=battbox_height * 2/3;
joint_diameter=3;
joint_setback=2;
joint_setback_width=2;
joint_setback_height=joint_height * 4/5;
joint_offset=5;
joint_spacing=50;
joint_v_clearance=0.3;
joint_d_clearance=0.3;

joint_max=1000;

battbox_edge_width_extra=0.3;
battbox_edge_width=joint_setback+joint_diameter+joint_d_clearance*2+battbox_edge_width_extra;
battbox_base_thickness=5;

function battbox_dimension(sizing, count) =
    sizing*count+battbox_spacing*(count-1)+battbox_edge_width*2;

battbox_width_w_bundle=battbox_dimension(bundle_width, battbox_count_wide);
battbox_length_w_bundle=battbox_dimension(bundle_length,battbox_count_long);

battbox_width_w_cylinder=battbox_dimension(battery_diameter+battery_clearance,battbox_count_wide);
battbox_length_w_cylinder=battbox_dimension(battery_diameter+battery_clearance,battbox_count_long);

battbox_width_w_block=battbox_dimension(battery_width+battery_clearance,battbox_count_wide);
battbox_length_w_block=battbox_dimension(battery_length+battery_clearance,battbox_count_long);

function battbox_width() =
    type == "bundle"   ? battbox_width_w_bundle   :
    type == "cylinder" ? battbox_width_w_cylinder :
 /* type == "block" */   battbox_width_w_block;
function battbox_length() =
    type == "bundle"   ? battbox_length_w_bundle   :
    type == "cylinder" ? battbox_length_w_cylinder :
 /* type == "block" */   battbox_length_w_block;

battery_cut_height=battbox_height*2;
battbox_inset_height=battbox_height*1/3;

battbox_inset_width=battbox_width() - battbox_edge_width*2;
battbox_inset_length=battbox_length() - battbox_edge_width*2;

function joint_count() =
    min(joint_max,floor((battbox_length() - joint_offset*2) / joint_spacing)+1);

module joint(cv,cd) {
    union() {
        translate([joint_diameter/2+cd+joint_setback,0,0])
        cylinder(joint_height+cv,d=joint_diameter+cd*2,$fn=10);

        translate([0,-(joint_setback_width/2+cd),0])
        cube([joint_setback+joint_diameter/2+cd,joint_setback_width+cd*2,joint_setback_height+cv]);
    }
}

module joints(cv,cd) {
    union() {
        for (j = [0:joint_count()-1]) {
            translate([0,joint_spacing*j,0])
            joint(cv,cd);
        }
    }
}

module joint_tabs() {
    translate([battbox_width(),joint_offset,0])
    joints(0,0);
}

module joint_sockets() {
    translate([0,joint_offset,0])
    joints(joint_v_clearance, joint_d_clearance);
}

module battbox_inset_cutout() {
    if (type == "bundle" || type == "cylinder") {
        translate([0,0,battbox_base_thickness+battbox_inset_height])
        union() {
            translate([battery_diameter/2,battery_diameter/2,0])
            cylinder(battery_cut_height,d=battery_diameter+battery_clearance*2);
            
            translate([battbox_inset_width-battery_diameter/2,battery_diameter/2,0])
            cylinder(battery_cut_height,d=battery_diameter+battery_clearance*2);
            
            translate([battery_diameter/2,battbox_inset_length-battery_diameter/2,0])
            cylinder(battery_cut_height,d=battery_diameter+battery_clearance*2);
            
            translate([battbox_inset_width-battery_diameter/2,battbox_inset_length-battery_diameter/2,0])
            cylinder(battery_cut_height,d=battery_diameter+battery_clearance*2);
            
            translate([0,battery_diameter/2,0])
            cube([battbox_inset_width,battbox_inset_length-battery_diameter,battery_cut_height]);
            
            translate([battery_diameter/2,0,0])
            cube([battbox_inset_width-battery_diameter,battbox_inset_length,battery_cut_height]);
        }
    }
    else if (type == "block") {
        translate([0,0,battbox_base_thickness+battbox_inset_height])
        cube([battbox_inset_width,battbox_inset_length,battery_cut_height]);
    }
}

module bundle_slot() {
    translate([0,0,battbox_base_thickness])
    union() {
        translate([battery_diameter/2,battery_diameter/2,0])
        cylinder(battery_cut_height,d=battery_diameter+battery_clearance*2);
        
        translate([bundle_width-battery_diameter/2,battery_diameter/2,0])
        cylinder(battery_cut_height,d=battery_diameter+battery_clearance*2);
        
        translate([battery_diameter/2,bundle_length-battery_diameter/2,0])
        cylinder(battery_cut_height,d=battery_diameter+battery_clearance*2);
        
        translate([bundle_width-battery_diameter/2,bundle_length-battery_diameter/2,0])
        cylinder(battery_cut_height,d=battery_diameter+battery_clearance*2);
        
        translate([0,battery_diameter/2,0])
        cube([bundle_width,bundle_length-battery_diameter,battery_cut_height]);
        
        translate([battery_diameter/2,0,0])
        cube([bundle_width-battery_diameter,bundle_length,battery_cut_height]);
    }
}

module cylinder_slot() {
    translate([battery_diameter_w_clearance/2,battery_diameter_w_clearance/2,battbox_base_thickness])
    cylinder(battery_cut_height,d=battery_diameter_w_clearance);
}

module box_slot() {
    translate([0,0,battbox_base_thickness])
    cube([battery_width_w_clearance,battery_length_w_clearance,battery_cut_height]);
}

module slot(w,l) {
    if (type == "bundle") {
        translate([battbox_edge_width+(bundle_width+battbox_spacing)*(w-1),battbox_edge_width+(bundle_length+battbox_spacing)*(l-1),0])
        bundle_slot();
    }
    
    else if (type == "cylinder") {
        translate([battbox_edge_width+(battery_diameter_w_clearance+battbox_spacing)*(w-1),battbox_edge_width+(battery_diameter_w_clearance+battbox_spacing)*(l-1),0])
        cylinder_slot();
    }
    else if (type == "block") {
        translate([battbox_edge_width+(battery_width_w_clearance+battbox_spacing)*(w-1),battbox_edge_width+(battery_length_w_clearance+battbox_spacing)*(l-1),0])
        box_slot();
    }
}

module battery_box() {
    difference() {
        union() {
            cube([battbox_width(),battbox_length(),battbox_height]);       
    
            joint_tabs();
        }

        joint_sockets();

        translate([battbox_edge_width,battbox_edge_width,0])
        battbox_inset_cutout();
    
        for (w = [1:battbox_count_wide]) {
            for(l = [1:battbox_count_long]) {
                slot(w,l);
            }
        }
    }
}

battery_box();
