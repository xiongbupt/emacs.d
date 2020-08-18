(defun tom|notebook-font()
  "Config font on notebook."
  (interactive)
  (if (eq system-type 'windows-nt)
      (progn
        ;; Setting English Font
        (set-face-attribute 'default nil :font "Ubuntu Mono 12")
        ;;(set-face-attribute 'default nil :font "Microsoft Yahei 11")
        ;; Chinese Font
        (dolist (charset '(kana han symbol cjk-misc bopomofo))
          (set-fontset-font (frame-parameter nil 'font)
                            charset
                            (font-spec :family "Microsoft Yahei" :size 16))))))

(defun tom|dell2412-font()
  "Config font on dell s2319.
   Ubuntu Mono 10 + Yahei 14 太小了
   Ubuntu Mono 12 + Yahei 16 比较合适
   "
  (interactive)
  (if (eq system-type 'windows-nt)
      (progn
        ;; Setting English Font
        ;;(set-face-attribute 'default nil :font "Microsoft Yahei 16")
        ;;(set-face-attribute 'default nil :font "Ubuntu Mono 14")
        (set-face-attribute 'default nil :font "Consolas 14")
        ;;(set-face-attribute 'default nil :font "Ubuntu Mono 14")
        ;; Chinese Font
        (dolist (charset '(kana han symbol cjk-misc bopomofo))
          (set-fontset-font (frame-parameter nil 'font)
                            charset
                            (font-spec :family "Microsoft Yahei" :size 18))))))

(defun my-apply-font ()
  (if (eq window-system 'w32)
      (progn
        ;; (display-mm-height)
        (if (> (display-mm-width) 293)
            (tom|dell2412-font))

        (if (eq (display-mm-width) 293)
            (tom|notebook-font)))))

;; 解决client模式下的字体问题
(add-hook 'after-make-frame-functions
          (lambda (frame)
            (select-frame frame)
            (if (window-system frame)
                (my-apply-font))))
;; 只有在windows模式下进行设置
(if window-system
    (my-apply-font))

(provide 'init-font)
