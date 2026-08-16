//  CAD BLOCK LIBRARY MANAGEMENT SYSTEM - DCL FILE
//  AutoLISP Dialog Definition Language (DCL)
//  Version: v1.10 | Lines: 240 | Size: 8 KB | Date: 2026-08-16 | Time: 18:45:30

cad_block_library : dialog {
    label = "CAD BLOCK LIBRARY MANAGEMENT v1.10 - Mauritius";
    initial_focus = "main_list";

    : row {
        : column {
            label = "MAIN FOLDER LIBRARY";
            width = 25;
            height = 12;
            : list_box {
                key = "main_list";
                width = 24;
                height = 11;
                multiple_select = false;
                tab_order = 1;
            }
        }
        
        : column {
            label = "SUB FOLDER LIBRARY";
            width = 25;
            height = 12;
            : list_box {
                key = "sub_list";
                width = 24;
                height = 11;
                multiple_select = false;
                tab_order = 2;
            }
        }
        
        : column {
            label = "BLOCKS FOLDER LIBRARY";
            width = 25;
            height = 12;
            : list_box {
                key = "folder_list";
                width = 24;
                height = 11;
                multiple_select = false;
                tab_order = 3;
            }
        }
    }
    
    : row {
        : text {
            label = "DRAWING BLOCKS - SELECT VIEW";
            width = 76;
        }
    }
    
    : row {
        : button {
            key = "preview_0";
            label = "BASE";
            width = 12;
            height = 2;
        }
        : button {
            key = "preview_1";
            label = "LEFT";
            width = 12;
            height = 2;
        }
        : button {
            key = "preview_2";
            label = "FRONT";
            width = 12;
            height = 2;
        }
        : button {
            key = "preview_3";
            label = "RIGHT";
            width = 12;
            height = 2;
        }
        : button {
            key = "preview_4";
            label = "PLAN";
            width = 12;
            height = 2;
        }
    }
    
    : row {
        : button {
            key = "preview_5";
            label = "SECTION";
            width = 12;
            height = 2;
        }
        : button {
            key = "preview_6";
            label = "3D";
            width = 12;
            height = 2;
        }
        : column {
            width = 40;
            height = 2;
        }
    }
    
    : row {
        : column {
            label = "BLOCK PREVIEW BEFORE INSERT";
            width = 40;
            height = 14;
            : image {
                key = "main_preview";
                width = 39;
                height = 13;
            }
        }
        
        : column {
            label = "BLOCK PROPERTIES CONTROLS";
            width = 34;
            height = 14;
            : text_multiline {
                key = "block_info";
                width = 33;
                height = 7;
                read_only = true;
                tab_order = 4;
            }
            : row {
                : text {
                    label = "LAYER";
                    width = 10;
                    fixed_width = true;
                }
                : edit_box {
                    key = "block_layer";
                    width = 20;
                    height = 1;
                    tab_order = 5;
                }
            }
            : row {
                : text {
                    label = "ROTATION";
                    width = 10;
                    fixed_width = true;
                }
                : edit_box {
                    key = "block_rotation";
                    width = 20;
                    height = 1;
                    tab_order = 6;
                }
            }
            : row {
                : text {
                    label = "SCALE";
                    width = 10;
                    fixed_width = true;
                }
                : edit_box {
                    key = "block_scale";
                    width = 20;
                    height = 1;
                    tab_order = 7;
                }
            }
        }
    }
    
    : row {
        : toggle {
            key = "explode_check";
            label = "EXPLODE";
            width = 12;
            height = 2;
        }
        : column {
            width = 40;
            height = 2;
        }
        : button {
            key = "insert_block";
            label = "INSERT";
            width = 12;
            height = 2;
            is_default = true;
        }
    }
    
    : row {
        : text {
            key = "status_bar";
            label = "Ready: Select a main folder to begin";
            width = 76;
        }
    }
    
    : row {
        : column {
            width = 40;
            height = 1;
        }
        : button {
            key = "accept";
            label = "CANCEL";
            width = 12;
            height = 2;
            is_cancel = true;
        }
    }
}
