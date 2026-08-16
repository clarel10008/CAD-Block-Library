;; Version: v1.10 | Lines: 575 | Size: 22 KB | Date: 2026-08-16 | Time: 18:45:30
;; CAD BLOCK LIBRARY MANAGEMENT SYSTEM
;; AutoLISP - SHOW BASE NAMES ONLY, WITH VARIANT PREVIEWS
;; Location: Mauritius (UTC+4 MUT)

;; ===== GLOBAL VARIABLES =====
(setq *lib_path* "D:\\CAD SETUP\\CATALOG\\CADBLOCKLIBRARY")
(setq *lib_path_user* nil)
(setq *main_folder* nil)
(setq *sub_folder* nil)
(setq *drawing* nil)
(setq *drawing_base_name* nil)
(setq *preview_idx* 0)
(setq *preview_variants* '())
(setq *dcl_id* nil)
(setq *main_folders_list* '())
(setq *sub_folders_list* '())
(setq *drawings_list* '())
(setq *drawings_full_paths* '())
(setq *explode_flag* nil)
(setq *preview_image_path* nil)
(setq *preview_labels* '("BASE" "LEFT" "FRONT" "RIGHT" "PLAN" "SECTION" "3D"))
(setq *variant_suffixes* '("-LEFT" "-FRONT" "-RIGHT" "-PLAN" "-SECTION" "-3D"))
(setq *insertion_count* 0)
(setq *last_scale* 1.0)
(setq *last_layer* "0")
(setq *last_rotation* 0)
(setq *error_log* '())
(setq *active_lib_path* nil)

;; ===== UTILITY: NORMALIZE PATH =====
(defun normalize_path (path)
    "Normalize path - ensure it ends with backslash"
    (if (and path (> (strlen path) 0))
        (progn
            (if (equal (substr path (strlen path)) "\\")
                (setq clean_path (substr path 1 (- (strlen path) 1)))
                (setq clean_path path)
            )
            clean_path
        )
        nil
    )
)

;; ===== UTILITY: PATH EXISTS CHECK =====
(defun path_exists (path)
    "Check if path (directory) exists using vl-directory-files"
    (if (null path)
        nil
        (progn
            (setq normalized (normalize_path path))
            (if (null normalized)
                nil
                (progn
                    (setq result (vl-catch-all-apply 'vl-directory-files 
                        (list normalized "*" -1)))
                    (if (vl-catch-all-error-p result)
                        nil
                        T
                    )
                )
            )
        )
    )
)

;; ===== UTILITY: DETECT LIBRARY PATH =====
(defun detect_lib_path ()
    "Auto-detect the library path"
    (princ "\n[INFO] Detecting library path...")
    
    (if (path_exists *lib_path*)
        (progn
            (princ (strcat "\n[SUCCESS] Found library path: " *lib_path*))
            (setq *active_lib_path* (strcat (normalize_path *lib_path*) "\\"))
            T
        )
        (progn
            (princ (strcat "\n[CHECKING] Library path not found: " *lib_path*))
            (princ "\n[FAILED] No valid library path found!")
            nil
        )
    )
)

;; ===== UTILITY: GET BASE NAME =====
(defun get_base_name (filename)
    "Extract base name removing all suffixes and .dwg extension"
    (if (and filename (> (strlen filename) 0))
        (progn
            (if (>= (strlen filename) 4)
                (setq name_no_ext (substr filename 1 (- (strlen filename) 4)))
                (setq name_no_ext filename)
            )
            
            (setq suffixes '("-3D" "-SECTION" "-PLAN" "-RIGHT" "-FRONT" "-LEFT"))
            (foreach suf suffixes
                (setq slen (strlen suf))
                (setq nlen (strlen name_no_ext))
                (if (>= nlen slen)
                    (if (equal (substr name_no_ext (+ (- nlen slen) 1)) suf)
                        (setq name_no_ext (substr name_no_ext 1 (- nlen slen)))
                    )
                )
            )
            name_no_ext
        )
        ""
    )
)

;; ===== UTILITY: CHECK IF ITEM IN LIST =====
(defun item_in_list (item lst)
    "Check if item exists in list"
    (if (null lst)
        nil
        (if (equal item (car lst))
            T
            (item_in_list item (cdr lst))
        )
    )
)

;; ===== UTILITY: ADD ERROR TO LOG =====
(defun log_error (error_msg)
    "Add error message to log"
    (setq *error_log* (append *error_log* (list error_msg)))
    (princ (strcat "\n[ERROR] " error_msg))
)

;; ===== UTILITY: ADD INFO TO LOG =====
(defun log_info (info_msg)
    "Add info message to log"
    (princ (strcat "\n[INFO] " info_msg))
)

;; ===== UTILITY: SAFE ATOI =====
(defun safe_atoi (str default)
    "Convert string to integer safely"
    (if (and str (> (strlen str) 0))
        (progn
            (setq result (vl-catch-all-apply 'atoi (list str)))
            (if (vl-catch-all-error-p result)
                default
                result
            )
        )
        default
    )
)

;; ===== UTILITY: SAFE ATOF =====
(defun safe_atof (str default)
    "Convert string to float safely"
    (if (and str (> (strlen str) 0))
        (progn
            (setq result (vl-catch-all-apply 'atof (list str)))
            (if (vl-catch-all-error-p result)
                default
                result
            )
        )
        default
    )
)

;; ===== MAIN COMMAND =====
(defun c:CADLIB ()
    "Open CAD Block Library - Main Entry Point"
    
    (princ "\n╔════════════════════════════════════════════════════════╗")
    (princ "\n║   CAD BLOCK LIBRARY MANAGEMENT SYSTEM v1.10            ║")
    (princ "\n║   Location: Mauritius (UTC+4 MUT)                      ║")
    (princ "\n╚════════════════════════════════════════════════════════╝")
    
    (if (not (findfile "CAD_BLOCK_LIBRARY.dcl"))
        (progn
            (alert "ERROR: CAD_BLOCK_LIBRARY.dcl not found!\n\nPlace the DCL file in your support folder.")
            (log_error "DCL file not found")
            (exit)
        )
    )
    
    (if (not (detect_lib_path))
        (progn
            (alert (strcat "ERROR: Library path not found!\n\n"
                          "Path: " *lib_path* "\n\n"
                          "Please create this folder or update the path in the LISP file."))
            (log_error "Library path not found")
            (exit)
        )
    )
    
    (setq *dcl_id* (load_dialog "CAD_BLOCK_LIBRARY.dcl"))
    (if (not *dcl_id*)
        (progn
            (alert "ERROR: Cannot load DCL file!")
            (log_error "Failed to load DCL file")
            (exit)
        )
    )
    
    (if (not (new_dialog "cad_block_library" *dcl_id*))
        (progn
            (alert "ERROR: Cannot create dialog!")
            (unload_dialog *dcl_id*)
            (log_error "Failed to create dialog")
            (exit)
        )
    )
    
    (setq *main_folders_list* (get_main_folders))
    
    (if (null *main_folders_list*)
        (progn
            (alert (strcat "WARNING: No folders found in library path!\n\n"
                          "Path: " *active_lib_path* "\n\n"
                          "Create sub-folders in this path for your block categories."))
            (log_error "No folders found in library")
        )
    )
    
    (start_list "main_list")
    (foreach folder *main_folders_list*
        (add_list folder)
    )
    (end_list)
    
    (set_tile "block_scale" (rtos *last_scale* 2 2))
    (set_tile "block_rotation" (rtos *last_rotation* 2 1))
    (set_tile "block_layer" *last_layer*)
    
    (set_tile "status_bar" (strcat "✓ Library: " *active_lib_path* " | Ready to begin"))
    
    (setup_dialog_actions)
    
    (start_dialog)
    (unload_dialog *dcl_id*)
    (princ)
)

;; ===== SETUP DIALOG ACTIONS =====
(defun setup_dialog_actions ()
    "Setup all dialog tile action handlers"
    
    (action_tile "main_list" "(on_main_list)")
    (action_tile "sub_list" "(on_sub_list)")
    (action_tile "folder_list" "(on_drawing_list)")
    
    (action_tile "preview_0" "(on_preview 0)")
    (action_tile "preview_1" "(on_preview 1)")
    (action_tile "preview_2" "(on_preview 2)")
    (action_tile "preview_3" "(on_preview 3)")
    (action_tile "preview_4" "(on_preview 4)")
    (action_tile "preview_5" "(on_preview 5)")
    (action_tile "preview_6" "(on_preview 6)")
    
    (action_tile "insert_block" "(on_insert)")
    (action_tile "explode_check" "(on_explode)")
    (action_tile "accept" "(done_dialog 0)")
)

;; ===== GET MAIN FOLDERS =====
(defun get_main_folders ()
    "Get list of main category folders from library path"
    (if (not *active_lib_path*)
        (progn
            (log_error "Active library path not set")
            '()
        )
        (if (not (path_exists *active_lib_path*))
            (progn
                (log_error (strcat "Library path not accessible: " *active_lib_path*))
                '()
            )
            (progn
                (setq all_items (vl-directory-files *active_lib_path* "*" -1))
                (setq clean '())
                (foreach item all_items
                    (if (and (not (equal item ".")) (not (equal item "..")))
                        (setq clean (append clean (list item)))
                    )
                )
                (vl-sort clean '<)
            )
        )
    )
)

;; ===== ON MAIN LIST SELECTED =====
(defun on_main_list ()
    "Handle main folder selection - DIALOG STAYS OPEN"
    (setq idx (safe_atoi (get_tile "main_list") -1))
    (if (and (>= idx 0) (< idx (length *main_folders_list*)))
        (progn
            (setq *main_folder* (nth idx *main_folders_list*))
            (setq *sub_folders_list* (get_sub_folders *main_folder*))
            
            (start_list "sub_list")
            (foreach sub *sub_folders_list*
                (add_list sub)
            )
            (end_list)
            
            (start_list "folder_list")
            (end_list)
            
            (clear_preview)
            (set_tile "status_bar" (strcat "✓ Category: " *main_folder* " (" (itoa (length *sub_folders_list*)) " sub-categories)"))
        )
    )
)

;; ===== GET SUB FOLDERS =====
(defun get_sub_folders (main_folder)
    "Get sub-category folders from main folder"
    (if (null main_folder)
        '()
        (progn
            (setq sub_path (strcat *active_lib_path* main_folder))
            (if (not (path_exists sub_path))
                (progn
                    (log_error (strcat "Sub folder path not found: " sub_path))
                    '()
                )
                (progn
                    (setq all_subs (vl-directory-files sub_path "*" -1))
                    (setq clean '())
                    (foreach sub all_subs
                        (if (and (not (equal sub ".")) (not (equal sub "..")))
                            (setq clean (append clean (list sub)))
                        )
                    )
                    (vl-sort clean '<)
                )
            )
        )
    )
)

;; ===== ON SUB LIST SELECTED =====
(defun on_sub_list ()
    "Handle sub-category selection - DIALOG STAYS OPEN"
    (setq idx (safe_atoi (get_tile "sub_list") -1))
    (if (and (>= idx 0) (< idx (length *sub_folders_list*)))
        (progn
            (setq *sub_folder* (nth idx *sub_folders_list*))
            
            (setq *drawings_list* '())
            (setq *drawings_full_paths* '())
            (get_unique_base_names *main_folder* *sub_folder*)
            
            (start_list "folder_list")
            (foreach dwg *drawings_list*
                (add_list dwg)
            )
            (end_list)
            
            (clear_preview)
            (set_tile "status_bar" (strcat "✓ Sub-Category: " *sub_folder* " (" (itoa (length *drawings_list*)) " blocks)"))
        )
    )
)

;; ===== GET UNIQUE BASE NAMES =====
(defun get_unique_base_names (main_folder sub_folder)
    "Extract ONLY unique base block names - no duplicates"
    (if (or (null main_folder) (null sub_folder))
        (progn
            (log_error "Missing folder parameters")
            (setq *drawings_list* '())
            (setq *drawings_full_paths* '())
        )
        (progn
            (setq dwg_path (strcat *active_lib_path* main_folder "\\" sub_folder))
            (setq all_dwgs (vl-directory-files dwg_path "*.dwg" 1))
            
            (if (null all_dwgs)
                (progn
                    (log_error (strcat "No DWG files found in: " dwg_path))
                    (setq *drawings_list* '())
                    (setq *drawings_full_paths* '())
                )
                (progn
                    (setq unique_names '())
                    (setq unique_paths '())
                    
                    (foreach dwg all_dwgs
                        (setq base_name (get_base_name dwg))
                        
                        (if (and base_name (not (item_in_list base_name unique_names)))
                            (progn
                                (setq unique_names (append unique_names (list base_name)))
                                (setq display_name (strcat base_name ".DWG"))
                                (setq unique_paths (append unique_paths (list display_name)))
                            )
                        )
                    )
                    
                    (setq sorted_paths (vl-sort unique_paths '<))
                    (setq *drawings_list* sorted_paths)
                    
                    (setq *drawings_full_paths* '())
                    (foreach disp_name sorted_paths
                        (setq base_name (substr disp_name 1 (- (strlen disp_name) 4)))
                        (setq *drawings_full_paths* (append *drawings_full_paths* (list base_name)))
                    )
                )
            )
        )
    )
)

;; ===== ON BLOCK SELECTED =====
(defun on_drawing_list ()
    "Handle base block selection - Load all variants - DIALOG STAYS OPEN"
    (setq idx (safe_atoi (get_tile "folder_list") -1))
    (if (and (>= idx 0) (< idx (length *drawings_list*)))
        (progn
            (setq *drawing* (nth idx *drawings_list*))
            (setq *drawing_base_name* (nth idx *drawings_full_paths*))
            
            (get_all_variants_for_block *drawing_base_name*)
            
            (setq *preview_idx* 0)
            (if (and *preview_variants* (nth 0 *preview_variants*))
                (load_and_show_preview (nth 0 *preview_variants*))
                (progn
                    (set_tile "main_preview" "")
                    (set_tile "status_bar" "⚠ No variants found for this block")
                )
            )
            
            (setq info (strcat "BLOCK: " *drawing* 
                              "\nLOCATION: " *main_folder* " > " *sub_folder*
                              "\nSTATUS: Ready to Insert ✓"
                              "\nVARIANTS: " (count_available_variants *preview_variants*)
                              "\nINSERTIONS: " (itoa *insertion_count*)))
            (set_tile "block_info" info)
            
            (set_tile "block_scale" (rtos *last_scale* 2 2))
            (set_tile "block_rotation" (rtos *last_rotation* 2 1))
            (set_tile "block_layer" *last_layer*)
            
            (set_tile "status_bar" (strcat "✓ Block: " *drawing* " - Click preview buttons to see variants"))
        )
    )
)

;; ===== GET ALL VARIANTS FOR BLOCK =====
(defun get_all_variants_for_block (base_name)
    "Get all variant files for a block"
    (if (null base_name)
        (setq *preview_variants* '())
        (progn
            (setq dwg_path (strcat *active_lib_path* *main_folder* "\\" *sub_folder* "\\"))
            (setq *preview_variants* '())
            
            (setq base_file (strcat dwg_path base_name ".dwg"))
            (if (findfile base_file)
                (setq *preview_variants* (append *preview_variants* (list base_file)))
                (setq *preview_variants* (append *preview_variants* (list nil)))
            )
            
            (foreach suf *variant_suffixes*
                (setq variant_file (strcat dwg_path base_name suf ".dwg"))
                (if (findfile variant_file)
                    (setq *preview_variants* (append *preview_variants* (list variant_file)))
                    (setq *preview_variants* (append *preview_variants* (list nil)))
                )
            )
        )
    )
)

;; ===== COUNT AVAILABLE VARIANTS =====
(defun count_available_variants (variant_list)
    "Count how many variants are available"
    (if (null variant_list)
        "0"
        (progn
            (setq count 0)
            (foreach v variant_list
                (if v
                    (setq count (+ count 1))
                )
            )
            (itoa count)
        )
    )
)

;; ===== ON PREVIEW BUTTON CLICKED =====
(defun on_preview (idx)
    "Handle preview button click - show variant preview"
    (setq *preview_idx* idx)
    (if (and *preview_variants* (>= idx 0) (< idx (length *preview_variants*)))
        (progn
            (setq variant_file (nth idx *preview_variants*))
            (load_and_show_preview variant_file)
            
            (if (< idx (length *preview_labels*))
                (setq label (nth idx *preview_labels*))
                (setq label "UNKNOWN")
            )
            
            (if variant_file
                (set_tile "status_bar" (strcat "✓ " *drawing* " - VIEW: " label))
                (set_tile "status_bar" (strcat "⚠ Variant not available - " label))
            )
        )
    )
)

;; ===== LOAD AND SHOW PREVIEW =====
(defun load_and_show_preview (dwg_file)
    "Load and display a DWG file as preview"
    (if (and dwg_file (findfile dwg_file))
        (progn
            (generate_thumbnail dwg_file)
            (if (and *preview_image_path* (findfile *preview_image_path*))
                (set_tile "main_preview" *preview_image_path*)
                (set_tile "main_preview" "")
            )
        )
        (progn
            (set_tile "main_preview" "")
        )
    )
)

;; ===== GENERATE THUMBNAIL =====
(defun generate_thumbnail (dwg_file)
    "Generate thumbnail image from DWG"
    (if (findfile dwg_file)
        (progn
            (setq temp_path (getenv "TEMP"))
            (setq preview_file (strcat temp_path "\\cadblock_preview.png"))
            
            (setq old_cmdecho (getvar "CMDECHO"))
            (setvar "CMDECHO" 0)
            
            (vl-catch-all-apply 'command
                (list "EXPORT" dwg_file preview_file "P")
            )
            
            (setvar "CMDECHO" old_cmdecho)
            (setq *preview_image_path* preview_file)
        )
        (setq *preview_image_path* nil)
    )
)

;; ===== CLEAR PREVIEW =====
(defun clear_preview ()
    "Clear preview and info"
    (set_tile "main_preview" "")
    (set_tile "block_info" "")
)

;; ===== INSERT BLOCK =====
(defun on_insert ()
    "Insert selected block variant"
    (if (and *drawing* *preview_variants* (>= *preview_idx* 0) (< *preview_idx* (length *preview_variants*)))
        (progn
            (setq fpath (nth *preview_idx* *preview_variants*))
            (if fpath
                (progn
                    (setq scale_str (get_tile "block_scale"))
                    (setq rotation_str (get_tile "block_rotation"))
                    (setq layer_str (get_tile "block_layer"))
                    
                    (setq scale (safe_atof scale_str 1.0))
                    (if (<= scale 0) (setq scale 1.0))
                    
                    (setq rotation (safe_atof rotation_str 0))
                    
                    (setq *last_scale* scale)
                    (setq *last_rotation* rotation)
                    (if (and layer_str (> (strlen layer_str) 0))
                        (setq *last_layer* layer_str)
                    )
                    
                    (if (< *preview_idx* (length *preview_labels*))
                        (setq variant_label (nth *preview_idx* *preview_labels*))
                        (setq variant_label "BASE")
                    )
                    
                    (done_dialog)
                    
                    (setq pt (getpoint "\nSelect insertion point: "))
                    (if pt
                        (progn
                            (vl-catch-all-apply 'command (list "INSERT" fpath pt scale scale rotation))
                            
                            (if (and layer_str (> (strlen layer_str) 0) (not (equal layer_str "0")))
                                (vl-catch-all-apply 'command (list "LAYER" "S" layer_str))
                            )
                            
                            (if *explode_flag*
                                (vl-catch-all-apply 'command (list "EXPLODE" "LAST"))
                            )
                            
                            (setq *insertion_count* (+ *insertion_count* 1))
                            
                            (alert (strcat "✓ SUCCESS!\n\nBlock: " *drawing* "\nVariant: " variant_label "\nScale: " (rtos scale 2 2) "\nRotation: " (rtos rotation 2 1) "°\n\nTotal Insertions: " (itoa *insertion_count*)))
                        )
                        (progn
                            (alert "✗ Insertion cancelled - No point selected")
                            (log_error "User cancelled insertion point selection")
                        )
                    )
                )
                (alert "✗ ERROR: This variant is not available!")
            )
        )
        (alert "✗ ERROR: Please select a block and preview variant first!")
    )
)

;; ===== TOGGLE EXPLODE =====
(defun on_explode ()
    "Toggle explode checkbox"
    (setq *explode_flag* (not *explode_flag*))
    (if *explode_flag*
        (set_tile "status_bar" "✓ EXPLODE: ON - Blocks will be exploded after insertion")
        (set_tile "status_bar" "EXPLODE: OFF - Blocks will be inserted normally")
    )
)

(princ "\n╔════════════════════════════════════════════════════════╗")
(princ "\n║   CAD BLOCK LIBRARY MANAGEMENT SYSTEM v1.10            ║")
(princ "\n║   Location: Mauritius (UTC+4 MUT)                      ║")
(princ "\n║   Type: CADLIB to start                                ║")
(princ "\n║                                                        ║")
(princ "\n║   Features:                                            ║")
(princ "\n║   ✓ Fixed path detection (vl-directory-files)          ║")
(princ "\n║   ✓ Single primary path only                           ║")
(princ "\n║   ✓ No duplicate base names                            ║")
(princ "\n║   ✓ Dialog stays open on selection                     ║")
(princ "\n║   ✓ 6 variant previews                                 ║")
(princ "\n║   ✓ Better error handling                              ║")
(princ "\n║   ✓ Improved validation                                ║")
(princ "\n╚════════════════════════════════════════════════════════╝\n")
(princ)
