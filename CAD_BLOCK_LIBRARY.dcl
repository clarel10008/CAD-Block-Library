//  CAD BLOCK LIBRARY MANAGEMENT SYSTEM - DCL FILE
//  AutoLISP Dialog Definition Language (DCL)
//  Version: v1.10 | Lines: 240 | Size: 8 KB | Date: 2026-08-16 | Time: 18:45:30

cad_block_library : dialog {
    label = "CAD BLOCK LIBRARY MANAGEMENT v1.10 - Mauritius";
    
    initial_focus = "main_list";
    
    // ===== ROW 1: THREE COLUMN LISTS =====
    : row {
        // COLUMN 1: MAIN FOLDER LIBRARY (LEFT)
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
        
        // COLUMN 2: SUB FOLDER LIBRARY (CENTER)
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
        
        // COLUMN 3: BLOCKS FOLDER LIBRARY (RIGHT)
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
    
    // ===== SEPARATOR LINE =====
    : row {
        fixed_width = true;
        width = 76;
        height = 1;
    }
    
    // ===== ROW 2: DRAWING BLOCKS - SELECT VIEW (LABEL) =====
    : row {
        : text {
            label = "DRAWING BLOCKS - SELECT VIEW";
            width = 76;
            height = 1;
        }
    }
    
    // ===== ROW 3: PREVIEW BUTTONS (5 VARIANTS) =====
    : row {
        fixed_width = true;
        width = 76;
        
        // Button 0: BASE PREVIEW
        : button {
            key = "preview_0";
            label = "BASE";
            width = 12;
            height = 2;
            fixed_width = true;
        }
        
        // Button 1: LEFT PREVIEW
        : button {
            key = "preview_1";
            label = "LEFT";
            width = 12;
            height = 2;
            fixed_width = true;
        }
        
        // Button 2: FRONT PREVIEW
        : button {
            key = "preview_2";
            label = "FRONT";
            width = 12;
            height = 2;
            fixed_width = true;
        }
        
        // Button 3: RIGHT PREVIEW
        : button {
            key = "preview_3";
            label = "RIGHT";
            width = 12;
            height = 2;
            fixed_width = true;
        }
        
        // Button 4: PLAN PREVIEW
        : button {
            key = "preview_4";
            label = "PLAN";
            width = 12;
            height = 2;
            fixed_width = true;
        }
    }
    
    // ===== ROW 4: LAST PREVIEW BUTTONS =====
    : row {
        fixed_width = true;
        width = 76;
        
        // Button 5: SECTION PREVIEW
        : button {
            key = "preview_5";
            label = "SECTION";
            width = 12;
            height = 2;
            fixed_width = true;
        }
        
        // Button 6: 3D PREVIEW
        : button {
            key = "preview_6";
            label = "3D";
            width = 12;
            height = 2;
            fixed_width = true;
        }
        
        // Spacer (40 width remaining)
        : column {
            width = 40;
            height = 2;
        }
    }
    
    // ===== SEPARATOR LINE =====
    : row {
        fixed_width = true;
        width = 76;
        height = 1;
    }
    
    // ===== ROW 5: MAIN PREVIEW AND BLOCK INFO =====
    : row {
        // BLOCK PREVIEW BEFORE INSERT (LEFT)
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
        
        // BLOCK PROPERTIES CONTROLS (RIGHT)
        : column {
            label = "BLOCK PROPERTIES CONTROLS";
            width = 34;
            height = 14;
            
            // Block Info Text Box
            : text_multiline {
                key = "block_info";
                width = 33;
                height = 7;
                read_only = true;
                tab_order = 4;
            }
            
            // LAYER Control
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
            
            // ROTATION Control
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
            
            // SCALE Control
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
    
    // ===== SEPARATOR LINE =====
    : row {
        fixed_width = true;
        width = 76;
        height = 1;
    }
    
    // ===== ROW 6: ACTION BUTTONS =====
    : row {
        fixed_width = true;
        width = 76;
        
        // EXPLODE Checkbox
        : toggle {
            key = "explode_check";
            label = "EXPLODE";
            width = 12;
            height = 2;
            fixed_width = true;
        }
        
        // Spacer
        : column {
            width = 40;
            height = 2;
        }
        
        // INSERT Button
        : button {
            key = "insert_block";
            label = "INSERT";
            width = 12;
            height = 2;
            fixed_width = true;
            is_default = true;
        }
    }
    
    // ===== ROW 7: STATUS BAR =====
    : row {
        : text {
            key = "status_bar";
            label = "Ready: Select a main folder to begin";
            width = 76;
            height = 1;
            fixed_width = true;
        }
    }
    
    // ===== SEPARATOR LINE =====
    : row {
        fixed_width = true;
        width = 76;
        height = 1;
    }
    
    // ===== ROW 8: BOTTOM BUTTONS =====
    : row {
        fixed_width = true;
        width = 76;
        
        // Spacer
        : column {
            width = 40;
            height = 2;
        }
        
        // CANCEL Button
        : button {
            key = "accept";
            label = "CANCEL";
            width = 12;
            height = 2;
            fixed_width = true;
            is_cancel = true;
        }
    }
}
