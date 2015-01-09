(require 'flycheck)

(defun flycheck-substitute-ghcmod (errors)
  "Substitute \\u0000 to \\n in ghc-mod's output."
  (dolist (err errors)
    (-when-let (message (flycheck-error-message err))
      (setf (flycheck-error-message err)
            (replace-regexp-in-string "\u0000" "\n" message 'fixed-case 'literal))))
  errors)

(flycheck-define-checker haskell-ghcmod
   "Haskell checker using ghc-mod."
   :command ("ghc-mod" "check" source-inplace)
   :error-patterns
   ((warning line-start (file-name) ":" line ":" column ":"
             "Warning: " (message) line-end)
    (error line-start (file-name) ":" line ":" column ":"
           (message) line-end))
   :error-filter
   (lambda (errors)
     (-> errors
         flycheck-substitute-ghcmod
         flycheck-dedent-error-messages
         flycheck-sanitize-errors))
   :modes haskell-mode)

(add-to-list 'flycheck-checkers 'haskell-ghcmod)

(provide 'flycheck-ghcmod)
