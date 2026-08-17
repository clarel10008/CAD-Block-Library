cad_block_library : dialog {
    label = "CAD BLOCK LIBRARY v1.10 - Mauritius";
    width = 80;
    height = 30;
    
    : list_box {
        key = "main_list";
        label = "Main Folder:";
        width = 25;
        height = 8;
    }
    
    : list_box {
        key = "sub_list";
        label = "Sub Folder:";
        width = 25;
        height = 8;
    }
    
    : list_box {
        key = "folder_list";
        label = "Blocks:";
        width = 25;
        height = 8;
    }
    
    : button {
        key = "preview_0";
        label = "BASE";
        width = 12;
    }
    
    : button {
        key = "preview_1";
        label = "LEFT";
        width = 12;
    }
    
    : button {
        key = "preview_2";
        label = "FRONT";
        width = 12;
    }
    
    : button {
        key = "preview_3";
        label = "RIGHT";
        width = 12;
    }
    
    : button {
        key = "preview_4";
        label = "PLAN";
        width = 12;
    }
    
    : button {
        key = "preview_5";
        label = "SECTION";
        width = 12;
    }
    
    : button {
        key = "preview_6";
        label = "3D";
        width = 12;
    }
    
    : text {
        key = "block_info";
        label = "Block Info:";
        width = 50;
    }
    
    : edit_box {
        key = "block_layer";
        label = "Layer:";
        width = 30;
    }
    
    : edit_box {
        key = "block_rotation";
        label = "Rotation:";
        width = 30;
    }
    
    : edit_box {
        key = "block_scale";
        label = "Scale:";
        width = 30;
    }
    
    : toggle {
        key = "explode_check";
        label = "Explode";
        width = 15;
    }
    
    : button {
        key = "insert_block";
        label = "INSERT BLOCK";
        width = 15;
        is_default = true;
    }
    
    : text {
        key = "status_bar";
        label = "Ready...";
        width = 80;
    }
    
    : button {
        key = "accept";
        label = "CLOSE";
        width = 15;
        is_cancel = true;
    }
}
