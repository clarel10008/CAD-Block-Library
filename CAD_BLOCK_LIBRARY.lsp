;; CAD BLOCK LIBRARY MANAGEMENT SYSTEM
;; AutoLISP - SHOW BASE NAMES ONLY, WITH VARIANT PREVIEWS
;; Version: v1.4 | Lines: 525 | Size: 19 KB | Date: 2026-08-16 | Time: 15:33:22 MUT

;; Global Variables
(setq *lib_path* "D:\\CAD SETUP\\CATALOG\\CADBLOCKLIBRARY\\")
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
(setq *preview_labels* '("LEFT" "FRONT" "RIGHT" "PLAN" "SECTION" "3D"))
(setq *variant_suffixes* '("-LEFT" "-FRONT" "-RIGHT" "-PLAN" "-SECTION" "-3D"))
(setq *insertion_count* 0)
(setq *last_scale* 1.0)
(setq *last_layer* "0")
(setq *last_rotation* 0)

;; ===== STRING SPLIT FUNCTION (Compatible with older AutoCAD) =====
(defun string_split (str delimiter)
    "Split a string by delimiter - Works with older AutoCAD versions"
    (setq result '())
    (setq current "")
    (setq i 0)
    (setq len (strlen str))
    (setq delim_len (strlen delimiter))
    
    (while (< i len)
        (setq char (substr str (+ i 1) delim_len))
        (if (equal char delimiter)
            (progn
                (setq result (append result (list current)))
                (setq current "")
                (setq i (+ i delim_len))
            )
            (progn
                (setq current (strcat current (substr str (+ i 1) 1)))
                (setq i (+ i 1))
            )
        )
    )
    
    (if (> (strlen current) 0)
        (setq result (append result (list current)))
    )
    result
)

;; ===== GET BASE NAME (Remove suffixes and extension) =====
(defun get_base_name (filename)
    "Extract base name removing all suffixes and .dwg extension"
    ;; Remove .dwg extension
    (setq name_no_ext (substr filename 1 (- (strlen filename) 4)))
    
    ;; Remove ALL variant suffixes
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

;; ===== CHECK IF ITEM IN LIST =====
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

;; ===== MAIN COMMAND =====
(defun c:CADLIB ()
    "Open CAD Block Library"
    
    ;; Load DCL
    (if (not (findfile "CAD_BLOCK_LIBRARY.dcl"))
        (progn
            (alert "CAD_BLOCK_LIBRARY.dcl not found!")
            (exit)
        )
    )
    
    (setq *dcl_id* (load_dialog "CAD_BLOCK_LIBRARY.dcl"))
    (if (not (new_dialog "cad_block_library" *dcl_id*))
        (progn
            (alert "Cannot load dialog!")
            (unload_dialog *dcl_id*)
            (exit)
        )
    )
    
    ;; Get and display main folders
    (setq *main_folders_list* (get_main_folders))
    
    ;; Populate main list
    (start_list "main_list")
    (foreach folder *main_folders_list*
        (add_list folder)
    )
    (end_list)
    
    ;; Set last used values
    (set_tile "block_scale" (rtos *last_scale* 2 2))
    (set_tile "block_rotation" (rtos *last_rotation* 2 1))
    (set_tile "block_layer" *last_layer*)
    
    (set_tile "status_bar" "Select a main folder to begin")
    
    ;; Setup all buttons and lists
    (action_tile "main_list" "(on_main_list)")
    (action_tile "sub_list" "(on_sub_list)")
    (action_tile "folder_list" "(on_drawing_list)")
    
    ;; 6 Preview buttons for variants
    (action_tile "preview_0" "(on_preview 0)")
    (action_tile "preview_1" "(on_preview 1)")
    (action_tile "preview_2" "(on_preview 2)")
    (action_tile "preview_3" "(on_preview 3)")
    (action_tile "preview_4" "(on_preview 4)")
    (action_tile "preview_5" "(on_preview 5)")
    
    (action_tile "insert_block" "(on_insert)")
    (action_tile "explode_check" "(on_explode)")
    (action_tile "accept" "(done_dialog 0)")
    
    (start_dialog)
    (unload_dialog *dcl_id*)
    (princ)
)

;; ===== GET MAIN FOLDERS =====
(defun get_main_folders ()
    "Get list of main category folders"
    (setq all_items (vl-directory-files *lib_path* "*" -1))
    (setq clean '())
    (foreach item all_items
        (if (and (not (equal item ".")) (not (equal item "..")))
            (setq clean (append clean (list item)))
        )
    )
    (vl-sort clean '<)
)

;; ===== ON MAIN LIST SELECTED =====
(defun on_main_list ()
    "Handle main folder selection"
    (setq idx (atoi (get_tile "main_list")))
    (if (and (>= idx 0) (< idx (length *main_folders_list*)))
        (progn
            (setq *main_folder* (nth idx *main_folders_list*))
            (setq *sub_folders_list* (get_sub_folders *main_folder*))
            
            ;; Populate sub list
            (start_list "sub_list")
            (foreach sub *sub_folders_list*
                (add_list sub)
            )
            (end_list)
            
            ;; Clear folder list
            (start_list "folder_list")
            (end_list)
            
            (clear_preview)
            (set_tile "status_bar" (strcat "Category: " *main_folder* " (" (itoa (length *sub_folders_list*)) " sub-categories)"))
        )
    )
)

;; ===== GET SUB FOLDERS =====
(defun get_sub_folders (main_folder)
    "Get sub-category folders"
    (setq sub_path (strcat *lib_path* main_folder "\\"))
    (setq all_subs (vl-directory-files sub_path "*" -1))
    (setq clean '())
    (foreach sub all_subs
        (if (and (not (equal sub ".")) (not (equal sub "..")))
            (setq clean (append clean (list sub)))
        )
    )
    (vl-sort clean '<)
)

;; ===== ON SUB LIST SELECTED =====
(defun on_sub_list ()
    "Handle sub-category selection"
    (setq idx (atoi (get_tile "sub_list")))
    (if (and (>= idx 0) (< idx (length *sub_folders_list*)))
        (progn
            (setq *sub_folder* (nth idx *sub_folders_list*))
            
            ;; Get ONLY UNIQUE BASE BLOCK NAMES (NO DUPLICATES)
            (setq *drawings_list* '())
            (setq *drawings_full_paths* '())
            (get_unique_base_names *main_folder* *sub_folder*)
            
            ;; Populate folder list with ONLY BASE NAMES
            (start_list "folder_list")
            (foreach dwg *drawings_list*
                (add_list dwg)
            )
            (end_list)
            
            (clear_preview)
            (set_tile "status_bar" (strcat "Sub-Category: " *sub_folder* " (" (itoa (length *drawings_list*)) " blocks)"))
        )
    )
)

;; ===== GET UNIQUE BASE NAMES (FIXED - NO DUPLICATES) =====
(defun get_unique_base_names (main_folder sub_folder)
    "Extract ONLY unique base block names - no duplicates"
    (setq dwg_path (strcat *lib_path* main_folder "\\" sub_folder "\\"))
    (setq all_dwgs (vl-directory-files dwg_path "*.dwg" 1))
    
    (setq unique_names '())
    (setq unique_paths '())
    
    (foreach dwg all_dwgs
        (setq base_name (get_base_name dwg))
        
        ;; Check if this base name is ALREADY in the list
        (if (not (item_in_list base_name unique_names))
            (progn
                ;; Add ONLY ONCE
                (setq unique_names (append unique_names (list base_name)))
                ;; Store display name with .DWG extension
                (setq display_name (strcat base_name ".DWG"))
                (setq unique_paths (append unique_paths (list display_name)))
            )
        )
    )
    
    ;; Sort and update globals
    (setq sorted_paths (vl-sort unique_paths '<))
    (setq *drawings_list* sorted_paths)
    
    ;; Update full paths to match sorted order
    (setq *drawings_full_paths* '())
    (foreach disp_name sorted_paths
        ;; Remove .DWG to get base name
        (setq base_name (substr disp_name 1 (- (strlen disp_name) 4)))
        (setq *drawings_full_paths* (append *drawings_full_paths* (list base_name)))
    )
)

;; ===== ON BLOCK SELECTED - LOAD VARIANTS =====
(defun on_drawing_list ()
    "Handle base block selection - Load all variants"
    (setq idx (atoi (get_tile "folder_list")))
    (if (and (>= idx 0) (< idx (length *drawings_list*)))
        (progn
            (setq *drawing* (nth idx *drawings_list*))
            (setq *drawing_base_name* (nth idx *drawings_full_paths*))
            
            ;; Get ALL VARIANTS of this block
            (get_all_variants_for_block *drawing_base_name*)
            
            ;; Show first variant (base) in main preview
            (setq *preview_idx* 0)
            (if (nth 0 *preview_variants*)
                (load_and_show_preview (nth 0 *preview_variants*))
                (progn
                    (set_tile "main_preview" "")
                    (set_tile "status_bar" "No variants found")
                )
            )
            
            ;; Update info
            (setq info (strcat "BLOCK: " *drawing* 
                              "\nLOCATION: " *main_folder* " > " *sub_folder*
                              "\nSTATUS: Ready to Insert"
                              "\nVARIANTS: " (count_available_variants *preview_variants*)
                              "\nINSERTIONS: " (itoa *insertion_count*)))
            (set_tile "block_info" info)
            
            ;; Set last used values
            (set_tile "block_scale" (rtos *last_scale* 2 2))
            (set_tile "block_rotation" (rtos *last_rotation* 2 1))
            (set_tile "block_layer" *last_layer*)
            
            (set_tile "status_bar" (strcat "Block: " *drawing* " - Click preview buttons to see variants"))
        )
    )
)

;; ===== GET ALL VARIANTS FOR BLOCK =====
(defun get_all_variants_for_block (base_name)
    "Get all variant files for a block (base + 6 variants)"
    (setq dwg_path (strcat *lib_path* *main_folder* "\\" *sub_folder* "\\"))
    (setq *preview_variants* '())
    
    ;; First add base file (no suffix)
    (setq base_file (strcat dwg_path base_name ".dwg"))
    (if (findfile base_file)
        (setq *preview_variants* (append *preview_variants* (list base_file)))
        (setq *preview_variants* (append *preview_variants* (list nil)))
    )
    
    ;; Add each variant
    (foreach suf *variant_suffixes*
        (setq variant_file (strcat dwg_path base_name suf ".dwg"))
        (if (findfile variant_file)
            (setq *preview_variants* (append *preview_variants* (list variant_file)))
            (setq *preview_variants* (append *preview_variants* (list nil)))
        )
    )
)

;; ===== COUNT AVAILABLE VARIANTS =====
(defun count_available_variants (variant_list)
    "Count how many variants are available"
    (setq count 0)
    (foreach v variant_list
        (if v
            (setq count (+ count 1))
        )
    )
    (itoa count)
)

;; ===== ON PREVIEW BUTTON CLICKED =====
(defun on_preview (idx)
    "Handle preview button click - show variant preview"
    (setq *preview_idx* idx)
    (if (and *preview_variants* (>= idx 0) (< idx (length *preview_variants*)))
        (progn
            (setq variant_file (nth idx *preview_variants*))
            (load_and_show_preview variant_file)
            
            ;; Update status
            (if (< idx (length *preview_labels*))
                (setq label (nth idx *preview_labels*))
                (setq label "")
            )
            
            (if variant_file
                (set_tile "status_bar" (strcat *drawing* " - VIEW: " label))
                (set_tile "status_bar" (strcat "Variant not available - " label))
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
                    ;; Get values
                    (setq scale_str (get_tile "block_scale"))
                    (setq rotation_str (get_tile "block_rotation"))
                    (setq layer (get_tile "block_layer"))
                    
                    ;; Validate scale
                    (if (and scale_str (> (strlen scale_str) 0))
                        (progn
                            (setq scale (atof scale_str))
                            (if (<= scale 0) (setq scale 1.0))
                        )
                        (setq scale 1.0)
                    )
                    
                    ;; Validate rotation
                    (if (and rotation_str (> (strlen rotation_str) 0))
                        (setq rotation (atof rotation_str))
                        (setq rotation 0)
                    )
                    
                    ;; Save values
                    (setq *last_scale* scale)
                    (setq *last_rotation* rotation)
                    (setq *last_layer* layer)
                    
                    ;; Close dialog
                    (done_dialog)
                    
                    ;; Get insertion point
                    (setq pt (getpoint "\nSelect insertion point: "))
                    (if pt
                        (progn
                            ;; Insert block
                            (command "-INSERT" fpath pt scale scale rotation)
                            
                            ;; Set layer
                            (if (and layer (not (equal layer "0")))
                                (command "LAYER" "S" layer)
                            )
                            
                            ;; Explode if needed
                            (if *explode_flag*
                                (command "EXPLODE" "LAST")
                            )
                            
                            ;; Increment counter
                            (setq *insertion_count* (+ *insertion_count* 1))
                            
                            ;; Get variant name
                            (if (< *preview_idx* (length *preview_labels*))
                                (setq variant_label (nth *preview_idx* *preview_labels*))
                                (setq variant_label "BASE")
                            )
                            
                            ;; Confirmation
                            (alert (strcat "Block '" *drawing* "' (" variant_label ") inserted!\n\nTotal: " (itoa *insertion_count*)))
                        )
                    )
                )
                (alert "This variant is not available!")
            )
        )
        (alert "Please select a block and a variant first!")
    )
)

;; ===== TOGGLE EXPLODE =====
(defun on_explode ()
    "Toggle explode"
    (setq *explode_flag* (not *explode_flag*))
    (if *explode_flag*
        (set_tile "status_bar" "EXPLODE: ON - Blocks will be exploded after insertion")
        (set_tile "status_bar" "EXPLODE: OFF")
    )
)

(princ "\n========================================")
(princ "\n>>> CAD BLOCK LIBRARY MANAGEMENT v1.4")
(princ "\n>>> Type CADLIB to start")
(princ "\n>>> FIXED: No duplicate base names")
(princ "\n========================================\n")
(princ)
