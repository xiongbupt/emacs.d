;;; init-local.el --- Settings and helpers for local.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:
;; 1. 抑制 session 警告
(add-to-list 'warning-suppress-types '(files missing-lexbind-cookie))

;; 2. 彻底解决 corfu 警告：屏蔽该包的加载
;;(setq-default package-load-list '((corfu-terminal nil) t))

;;(org-latex-pdf-process '("xelatex -interaction nonstopmode %f" "xelatex -interaction nonstopmode %f"))
;; load solarized-theme
;; https://github.com/sellout/emacs-color-theme-solarized
(setq frame-background-mode 'dark)
(let ((basedir (expand-file-name "~/.emacs.d/elpa-30.2/themes/")))
  (when (file-directory-p basedir)
    ;; 只有目录存在时才执行后续逻辑
    (dolist (f (directory-files basedir))
      (let ((full-path (concat basedir f)))
        (if (and (not (member f '("." "..")))
                 (file-directory-p full-path))
            (add-to-list 'custom-theme-load-path full-path))))

    ;; 将 load-theme 放在判断内部，防止主题文件找不到而报错
    (condition-case nil
        (load-theme 'sanityinc-solarized-dark t)
      (error (message "Warning: Could not load sanityinc-solarized-dark theme.")))))


(require 'package)
(eval-when-compile
  (require 'use-package))
;; 1. 强制重置禁用名单
(setq package-load-list '(all))
(setq package-ignored-packages nil)

;; 2. 针对 Emacs 30 的底层修复：强制清理被标记为 disabled 的内置/外部包缓存
(setq package--builtins (delq (assq 'tomelr package--builtins) package--builtins))
(setq package--builtins (delq (assq 'yasnippet package--builtins) package--builtins))

;; 3. 重新初始化
(package-initialize)

(set-face-attribute 'default nil :height 140)
(set-default 'truncate-lines t)
(require-package 'sis)
;; (require-package 'plantuml-mode)
;; (require-package 'use-pacage)
;; (require-package 'ox-hugo)
(require-package 'org-download)
(require-package 'company)
(require-package 'posframe)
(require-package 'which-key)
(require-package 'isearch-mb)
(require-package 'rime)
;; (require 'org-download)
;; 1. 修正后的 Rime 辅助函数 (添加了 &rest _ 解决参数报错)
(defun my/rime-ensure-ascii-safe (&rest _)
  (interactive)
  (when (string= current-input-method "rime")
    (setq rime-is-ascii-mode t)
    (ignore-errors (rime--redisplay))))

;; 强制加载 org-download，确保 M-x 能找到命令
(require 'org-download)

(with-eval-after-load 'org-download
  ;; 1. 跨系统截图命令判定 (重点调整了 Mac 下的 screenshot 命令)
  (setq org-download-screenshot-method
        (cond
         ;; macOS: screenshot 命令用 screencapture (唤起准星)
         ;;        clipboard 命令会自动使用 pngpaste (如果安装了)
         ((eq system-type 'darwin) "screencapture -i %s")

         ;; Linux: 保持原样
         ((eq system-type 'gnu/linux)
          (if (string= (getenv "XDG_SESSION_TYPE") "wayland")
              "wl-paste > %s"
            "xclip -selection clipboard -t image/png -o > %s"))))

  ;; 2. 基础路径与缩放设置
  (setq-default org-download-image-dir "./images")
  (setq org-download-image-org-width 400)
  (setq org-download-heading-lvl nil)

  ;; 3. 联动 Rime：截图或粘贴前切英文
  (advice-add 'org-download-screenshot :before #'my/rime-ensure-ascii-safe)
  (advice-add 'org-download-clipboard :before #'my/rime-ensure-ascii-safe)

  ;; 4. 快捷键
  (with-eval-after-load 'org
    (define-key org-mode-map (kbd "C-c d s") 'org-download-screenshot)
    (define-key org-mode-map (kbd "C-c d v") 'org-download-clipboard)))

;; 启用插件
(add-hook 'dired-mode-hook 'org-download-enable)
(add-hook 'org-mode-hook 'org-download-enable)

(use-package yasnippet
  :ensure t
  :config
  (add-to-list 'yas-snippet-dirs "~/Dropbox/org/snippets")
  (yas-global-mode 1))

(use-package autoinsert
  :init
  (setq auto-insert-mode 1)
  (setq auto-insert-query nil)
  :config
  ;; 关联后缀与处理函数
  (define-auto-insert
    '("\\.org\\'" . "Org Default Template")
    (lambda ()
      (org-mode)
      (let ((snippet (yas-lookup-snippet "default-org-template" 'org-mode)))
        (if snippet
            (progn
              (delete-region (point-min) (point-max))
              (yas-expand-snippet snippet))
          (message "Snippet 'default-org-template' not found")))))

  ;; 核心补丁：如果打开新文件没反应，强制跑一次 auto-insert
  (add-hook 'find-file-hook
            (lambda ()
              (when (and (buffer-file-name)
                         (string-match-p "\\.org\\'" (buffer-file-name))
                         (zerop (buffer-size)))
                (auto-insert)))))
(use-package yasnippet-snippets
  :ensure t
  :after yasnippet)

(use-package sis
  ;; :hook
  ;; enable the /follow context/ and /inline region/ mode for specific buffers
  ;; (((text-mode prog-mode) . sis-follow-context-mode)
  ;;  ((text-mode prog-mode) . sis-inline-mode))

  :config

  ;; Windows
  ;;(sis-ism-lazyman-config "1033" "2052" 'im-select)
  (when *is-a-mac*
    (sis-ism-lazyman-config
     "com.apple.keylayout.US"
     "im.rime.inputmethod.Squirrel.Hans" 'macism ))
  ;;(when *sys/wsl*
  ;;  (setq sis-english-source "1033")
  ;;  (setq sis-other-source "2052")
  ;;  (setq sis-do-get (lambda ()
  ;;                     (sis--ensure-dir
  ;;                      (string-trim (shell-command-to-string "im-select.exe")))))
  ;;  (setq sis-do-set (lambda(source)
  ;;                     (sis--ensure-dir
  ;;                      (call-process "/bin/bash" nil t nil "-c" (concat "im-select.exe " source)))))
  ;;  (setq sis-external-ism "im-select.exe"))
  ;; enable the /cursor color/ mode
  (sis-global-cursor-color-mode t)
  ;; enable the /respect/ mode
  (sis-global-respect-mode t)
  (sis-global-context-mode t)
  ;; enable the /follow context/ mode for all buffers
  ;; (sis-global-follow-context-mode t)
  ;; enable the /inline english/ mode for all buffers
  (sis-global-inline-mode t)
  )

;;  (setq sis-ism-lazyman-config "1033" "2052" 'im-select)
;;  (setq evil-default-cursor t))
;;
;;  ;; enable the /cursor color/ mode
;;  (setq sis-global-cursor-color-mode t)
;;  ;; enable the /respect/ mode
;;  (setq sis-global-respect-mode t)
;;  ;; enable the /follow context/ mode for all buffers
;;  (setq sis-global-follow-context-mode t)
;;  ;; enable the /inline english/ mode for all buffers
;;  (setq sis-global-inline-mode t)

;;(require 'init-evil) ; init-evil dependent on init-clipboard

;;(require-package 'rime)
;;(use-package rime
;;  :custom
;;  (rime-librime-root "~/.emacs.d/librime/dist")
;;  (default-input-method "rime")
;;  (rime-user-data-dir "~/Library/Rime")
;;  (rime-share-data-dir "~/Library/Rime")
;;  (setq rime-posframe-properties
;;        (list :font "sarasa ui sc"
;;              :internal-border-width 10))
;;  )
;;(setq org-plantuml-jar-path (expand-file-name "~/.emacs.d/plantuml.jar"))

;; 下面参考来源https://github.com/skuro/plantuml-mode
;;(setq plantuml-jar-path "~/.emacs.d/plantuml.jar")
;;(setq plantuml-default-exec-mode 'jar)
;;(setq plantuml-default-exec-mode 'executable)
;;(setq org-plantuml-exec-mode 'plantuml)
;;(setq org-plantuml-executable-path "~/bin/plantuml")
;;(setq org-plantuml-executable-args '("-headless" "-charset UTF-8"))

;; Enable plantuml-mode for PlantUML files
;;(add-to-list 'auto-mode-alist '("\\.plantuml\\'" . plantuml-mode))
;;(add-to-list 'org-src-lang-modes '("plantuml" . plantuml))
;; 参考https://github.com/d12frosted/homebrew-emacs-plus/issues/383
;;(setq insert-directory-program "gls" dired-use-ls-dired t)
;;(setq dired-listing-switches "-al --group-directories-first")
;;(global-set-key (kbd "C-c o")
;;(lambda () (interactive) (find-file "~/organizer.org"))
(global-set-key (kbd "C-c o")
                (lambda () (interactive) (find-file "~/organizer.org")))
(set-register ?o (cons 'file "~/organizer.org"))
(setq org-default-notes-file "~/organizer.org")
;;hugo设置
;;(with-eval-after-load 'ox
;;  (require 'ox-hugo))
;;(custom-set-faces '(org-table ((t (:foreground "#a9a1e1" :height 120 :family "Noto Sans Mono CJK SC Regular")))))
(add-hook 'org-mode-hook (lambda () (setq toggle-truncate-lines t)))
(autoload 'markdown-mode "markdown-mode"
  "Major mode for editing Markdown files" t)
(add-to-list 'auto-mode-alist
             '("\\.\\(?:md\\|markdown\\|mkd\\|mdown\\|mkdn\\|mdwn\\)\\'" . markdown-mode))

(autoload 'gfm-mode "markdown-mode"
  "Major mode for editing GitHub Flavored Markdown files" t)
(add-to-list 'auto-mode-alist '("README\\.md\\'" . gfm-mode))

(with-eval-after-load 'markdown-mode
  (define-key markdown-mode-map (kbd "C-c C-e") #'markdown-do))
;; Add a rule to file-coding-system-alist to try a list of coding systems
;; for any file that doesn't match a more specific rule earlier in the list.
;; This effectively provides a preferred order for initial guessing.

;; (setq file-coding-system-alist
;;       '(
;;         (".*" . (ucs-bom utf-8 cp936 gb18030 big5 euc-jp euc-kr iso-8859-1))
;;         ))
(setq debug-on-error t)
(defun setup-chinese-font ()
  "设置中英文、符号及 Emoji 字体，解决加粗乱码与符号显示问题。"
  (interactive)
  (cond
   ;; --- macOS 配置 ---
   ((eq system-type 'darwin)
    (let ((english-font "Monaco")
          (chinese-font "PingFang SC")
          (emoji-font "Apple Color Emoji"))

      ;; 1. 基础英文字体
      (set-face-attribute 'default nil :family english-font :height 140)
      (setq face-font-rescale-alist '(("PingFang SC" . 1.1)))

      ;; 2. 遍历样式：确保中文和符号在粗体/斜体下不乱码
      (dolist (weight '(normal bold))
        (dolist (slant '(normal italic)) ; 修正了这里的括号，确保 let 在循环内
          (let ((zh-spec (font-spec :family chinese-font :weight weight :slant slant)))
            ;; 覆盖汉字、中日韩标点
            (dolist (charset '(han cjk-misc bopomofo kana))
              (set-fontset-font t charset zh-spec nil 'prepend))
            ;; 3. 符号处理：先用中文字体覆盖通用符号
            (set-fontset-font t 'symbol zh-spec nil 'prepend))))

      ;; 4. 【关键修正】制表符强制回归英文字体
      ;; 解决 PingFang SC 可能导致的 ├ 乱码或对齐问题
      (set-fontset-font t '(#x2500 . #x257F) (font-spec :family english-font))

      ;; 5. 专门处理 Emoji 脚本
      (set-fontset-font t 'emoji (font-spec :family emoji-font) nil 'prepend)))

   ;; --- Linux (飞腾/UOS) 配置 ---
   ((eq system-type 'gnu/linux)
    (let ((english-font "Source Code Pro")
          (chinese-font "Noto Sans CJK SC")
          (emoji-font "Noto Color Emoji"))

      ;; 1. 基础英文字体
      (set-face-attribute 'default nil :family english-font :height 150)
      (setq face-font-rescale-alist '(("Noto Sans CJK SC" . 1.0)))

      ;; 2. 遍历样式
      (dolist (weight '(normal bold))
        (dolist (slant '(normal italic))
          (let ((zh-spec (font-spec :family chinese-font :weight weight :slant slant)))
            (dolist (charset '(han cjk-misc bopomofo kana))
              (set-fontset-font t charset zh-spec nil 'prepend))
            (set-fontset-font t 'symbol zh-spec nil 'prepend))))

      ;; 3. 【关键修正】Linux 下同样强制制表符使用等宽英文
      (set-fontset-font t '(#x2500 . #x257F) (font-spec :family english-font))

      ;; 4. 专门处理 Emoji 脚本
      (set-fontset-font t 'emoji (font-spec :family emoji-font) nil 'prepend)))))


;; --- 关键：挂载到所有可能的入口 ---

;; 1. 立即执行（针对普通启动）
(setup-chinese-font)

;; 2. 针对 emacsclient (Daemon) 模式
;; 当你用 ew 脚本唤起新窗口时，这个 hook 确保配置重新加载
(add-hook 'server-after-make-frame-hook 'setup-chinese-font)

;; 3. 兜底方案：如果上述两个都没解决 symbol 乱码，强制对所有 frame 应用一次
(add-hook 'after-make-frame-functions
          (lambda (frame)
            (with-selected-frame frame (setup-chinese-font))))



;;;使用中文的分词配置
;;;https://github.com/kanglmf/emacs-chinese-word-segmentation
(add-to-list 'load-path "~/.emacs.d/chinese")
(setq cns-process-type 'shell)
(setq cns-prog "~/.emacs.d/chinese/cnws")
(setq cns-dict-directory "~/.emacs.d/chinese/cppjieba/dict")
(setq cns-recent-segmentation-limit 20) ; default is 10
(setq cns-debug nil) ; disable debug output, default is t
(require 'cns nil t)
(when (featurep 'cns)
  (add-hook 'find-file-hook 'cns-auto-enable))

;;;参考https://pavinberg.github.io/emacs-book/zh/optimization/，添加相关的插件
(use-package counsel
  :ensure t)

(use-package ivy
  :ensure t
  :init
  (ivy-mode 1)
  (counsel-mode 1)
  :config
  (setq ivy-use-virtual-buffers t)
  (setq search-default-mode #'char-fold-to-regexp)
  (setq ivy-count-format "(%d/%d) ")
  :bind
  (("C-s" . 'swiper)
   ("C-x b" . 'ivy-switch-buffer)
   ("C-c v" . 'ivy-push-view)
   ("C-c s" . 'ivy-switch-view)
   ("C-c V" . 'ivy-pop-view)
   ("C-x C-@" . 'counsel-mark-ring); 在某些终端上 C-x C-SPC 会被映射为 C-x C-@，比如在 macOS 上，所以要手动设置
   ("C-x C-SPC" . 'counsel-mark-ring)
   :map minibuffer-local-map
   ("C-r" . counsel-minibuffer-history)))

(use-package amx
  :ensure t
  ;; 只有在非 -Q 模式下才尝试配置和开启
  :if user-init-file
  :custom
  ;; 注意：路径必须加双引号
  (amx-save-file "~/.emacs.d/.amx-items")
  :config
  (amx-mode 1))

(use-package ace-window
  :ensure t
  :bind (("C-x o" . 'ace-window)))

(use-package mwim
  :ensure t
  :bind
  ("C-a" . mwim-beginning-of-code-or-line)
  ("C-e" . mwim-end-of-code-or-line))

(use-package hydra
  :ensure t)

(use-package use-package-hydra
  :ensure t
  :after hydra)


(use-package undo-tree
  :ensure t
  :after hydra
  ;; 1. 初始化设置
  :init
  (global-undo-tree-mode) ; 全局启用 undo-tree

  ;; 2. 变量配置
  :custom
  (undo-tree-auto-save-history t) ; 自动保存撤销历史到文件
  (undo-tree-history-directory-alist '(("." . "~/.emacs.d/.undo"))) ; 统一存放历史文件，避免污染项目目录

  ;; 3. 快捷键绑定
  :bind ("C-x C-h u" . hydra-undo-tree/body)

  ;; 4. Hydra 菜单定义
  :hydra (hydra-undo-tree (:hint nil)
                          "
  _p_: undo  _n_: redo  _s_: save  _l_: load  _u_: visualize  _q_: quit
          "
                          ("p" undo-tree-undo)
                          ("n" undo-tree-redo)
                          ("s" undo-tree-save-history)
                          ("l" undo-tree-load-history)
                          ("u" undo-tree-visualize :color blue)
                          ("q" nil :color blue)))

(use-package multiple-cursors
  :ensure t
  :after hydra
  :bind
  (("C-x C-h m" . hydra-multiple-cursors/body)
   ("C-S-<mouse-1>" . mc/toggle-cursor-on-click))
  :hydra
  (hydra-multiple-cursors
   (:hint nil)
   "
Up^^       Down^^      Miscellaneous      % 2(mc/num-cursors) cursor%s(if (> (mc/num-cursors) 1) \"s\" \"\")
------------------------------------------------------------------
 [_p_]  Prev   [_n_]  Next   [_l_] Edit lines [_0_] Insert numbers
 [_P_]  Skip   [_N_]  Skip   [_a_] Mark all  [_A_] Insert letters
 [_M-p_] Unmark  [_M-n_] Unmark  [_s_] Search   [_q_] Quit
 [_|_] Align with input CHAR    [Click] Cursor at point"
   ("l" mc/edit-lines :exit t)
   ("a" mc/mark-all-like-this :exit t)
   ("n" mc/mark-next-like-this)
   ("N" mc/skip-to-next-like-this)
   ("M-n" mc/unmark-next-like-this)
   ("p" mc/mark-previous-like-this)
   ("P" mc/skip-to-previous-like-this)
   ("M-p" mc/unmark-previous-like-this)
   ("|" mc/vertical-align)
   ("s" mc/mark-all-in-region-regexp :exit t)
   ("0" mc/insert-numbers :exit t)
   ("A" mc/insert-letters :exit t)
   ("<mouse-1>" mc/add-cursor-on-click)
   ;; Help with click recognition in this hydra
   ("<down-mouse-1>" ignore)
   ("<drag-mouse-1>" ignore)
   ("q" nil)))

(global-set-key (kbd "C-j") nil)
;; 删去光标所在行（在图形界面时可以用 "C-S-<DEL>"，终端常会拦截这个按法)
(global-set-key (kbd "C-j C-k") 'kill-whole-line)
(use-package avy
  :ensure t
  :bind
  (("C-j C-SPC" . avy-goto-char-timer)))
(add-hook 'org-mode-hook 'visual-line-mode)
(setq truncate-lines nil)
(provide 'init-local)
