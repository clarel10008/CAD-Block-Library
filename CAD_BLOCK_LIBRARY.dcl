//  CAD BLOCK LIBRARY MANAGEMENT SYSTEM - DCL FILE
//  AutoLISP Dialog Definition Language (DCL)
//  Version: v1.10 | Lines: 240 | Size: 8 KB | Date: 2026-08-16 | Time: 18:45:30

cad_block_library : dialog {
    label = "CAD BLOCK LIBRARY MANAGEMENT v1.10 - Mauritius";
    
    : boxed_column {
        label = "Select Libraries";
        : row {
            : column {
                label = "Main Folder";
                : list_box {
                    key = "main_list";
                    width = 20;
                    height = 10;
                }
            }
            : column {
                label = "Sub Folder";
                : list_box {
                    key = "sub_list";
                    width = 20;
                    height = 10;
                }
            }
            : column {
                label = "Blocks";
                : list_box {
                    key = "folder_list";
                    width = 20;
                    height = 10;
                }
            }
        }
    }
    
    : boxed_row {
        label = "Preview Variants";
        : button { key = "preview_0"; label = "BASE"; width = 10; }
        : button { key = "preview_1"; label = "LEFT"; width = 10; }
        : button { key = "preview_2"; label = "FRONT"; width = 10; }
        : button { key = "preview_3"; label = "RIGHT"; width = 10; }
        : button { key = "preview_4"; label = "PLAN"; width = 10; }
        : button { key = "preview_5"; label = "SECTION"; width = 10; }
        : button { key = "preview_6"; label = "3D"; width = 10; }
    }
    
    : row {
        : column {
            label = "Preview";
            : image {
                key = "main_preview";
                width = 30;
                height = 12;
            }
        }
        : column {
            label = "Block Info";
            : text_multiline {
                key = "block_info";
                width = 30;
                height = 6;
                read_only = true;
            }
            : text { label = "Layer:"; }
            : edit_box { key = "block_layer"; width = 30; }
            : text { label = "Rotation:"; }
            : edit_box { key = "block_rotation"; width = 30; }
            : text { label = "Scale:"; }
            : edit_box { key = "block_scale"; width = 30; }
        }
    }
    
    : row {
        : toggle { key = "explode_check"; label = "Explode After Insert"; width = 20; }
        : button { key = "insert_block"; label = "INSERT BLOCK"; width = 15; is_default = true; }
    }
    
    : text { key = "status_bar"; label = "Ready..."; }
    
    : row {
        : button { key = "accept"; label = "CLOSE"; width = 15; is_cancel = true; }
    }
}
