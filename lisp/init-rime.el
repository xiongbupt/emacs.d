;;; -*- lexical-binding: t; -*-
;;; init-rime.el  --- Custom configuration
;;; Commentary
(require-package 'rime)
(require 'posframe)

(use-package rime
  :ensure t
  :custom
  (default-input-method "rime")
  (rime-user-data-dir "~/.emacs.d/Rime")
  (rime-show-candidate 'minibuffer)
  (rime-inline-ascii-trigger 'shift-l)

  ;; (rime-disable-predicates '(rime-predicate-prog-in-code-p
  ;;                            rime-predicate-org-in-src-block-p
  ;;                            rime-predicate-org-latex-mode-p
  ;;                            rime-predicate-in-code-string-p))
  ;; (rime-inline-predicates '(
  ;;                           ;; rime-predicate-space-after-cc-p ;;在中文字符且有空格之后
  ;;                           ;; rime-predicate-current-uppercase-letter-p ;;将要输入的为大写字母时
  ;;                           ;;rime-predicate-current-input-punctuation-p ;; 当要输入的是符号时
  ;;                           rime-predicate-punctuation-after-space-cc-p ;; 当要在中文字符且有空格之后输入符号时
  ;;                           ;;rime-predicate-punctuation-line-begin-p ;;在行首要输入符号时
  ;;       		    ))


  :init
  ;; 路径逻辑放在 init 确保在加载前生效
  (cond
   ((eq system-type 'darwin)
    (setq rime-emacs-module-header-root "/opt/homebrew/include")
    (setq rime-librime-root "/opt/homebrew/opt/librime")
    (setq rime-disable-predicates 
          '(rime-predicate-prog-in-code-p
            rime-predicate-org-in-src-block-p
            rime-predicate-org-latex-mode-p
            rime-predicate-in-code-string-p))
    )
   ((eq system-type 'gnu/linux)
    (setq rime-emacs-module-header-root "/usr/include")
    ;; 指向 librime.so 所在的父目录，通常 /usr/lib/aarch64-linux-gnu
    ;; 如果不确定，写 "/usr" 也是可以的，插件会自动搜索
    (setq rime-librime-root "/usr/lib/aarch64-linux-gnu")))

  :config
  ;; 这里的目的是：如果模块没加载，就尝试编译
  ;; 删掉报错的 rime--module-loaded-p，改用 featurep 检查
  (unless (featurep 'rime-module)
    (ignore-errors (rime-compile-module)))
  )
(defun rime-predicate-special-ascii-line-begin-p ()
  "If '/' or '#' at the beginning of the line."
  (and (> (point) (save-excursion (back-to-indentation) (point)))
       (let ((string (buffer-substring (point) (max (line-beginning-position) (- (point) 80)))))
         (string-match-p "^[\/#]" string))))
(require-package 'isearch-mb)
(global-set-key (kbd "C-s") 'isearch-forward-regexp)
(global-set-key (kbd "C-r") 'isearch-backward-regexp)

(isearch-mb-mode 1)
(setq-default
 ;; Show match count next to the minibuffer prompt
 isearch-lazy-count t
 ;; Don't be stingy with history; default is to keep just 16 entries
 search-ring-max 200
 regexp-search-ring-max 200
 isearch-regexp-lax-whitespace t
 ;; Swiper style: space matches any sequence of characters in a line.
 search-whitespace-regexp ".*?"
 ;; Alternative: space matches whitespace, newlines and punctuation.
 search-whitespace-regexp "\\W+")
;;(require-package 'websocket)
;;(add-to-list 'load-path "~/.emacs.d/lisp/deno-bridge")
;;(require 'deno-bridge)
;;(add-to-list 'load-path (expand-file-name "~/.emacs.d/lisp/deno-bridge-jieba"))
;;(require 'deno-bridge-jieba)
;; (global-visual-line-mode 1)
(provide 'init-rime)
;;;;; init-rime.el ends here
