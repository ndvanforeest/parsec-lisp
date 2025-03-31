;; Set the package installation directory so that packages aren't stored in the
;; ~/.emacs.d/elpa path.
(require 'package)
(setq package-user-dir (expand-file-name "./.packages"))
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

;; Initialize the package system
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))


(unless (package-installed-p 'htmlize)
  (package-install 'htmlize))

(unless (package-installed-p 'ox-tufte)
  (package-install 'ox-tufte))


;; Load the publishing system
(require 'ox-publish)
(require 'ox-tufte)


;; Load org-mode, to be able to evaluate the code blocks
(require 'org)
(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t))) ;; Ensure Emacs Lisp execution

(setq org-export-babel-evaluate t) ;; Allow code execution on export
(setq org-confirm-babel-evaluate nil) ;; Do not ask for confirmation before executing

;; Customize the HTML output
;; the font colors offered by htmlize (org-html-htmlize-generate-css are not very clear on my screen.
(setq org-html-validation-link t              ;; Don't show validation link
      org-html-head-include-scripts nil       ;; Use our own scripts
      org-html-head-include-default-style nil ;; Use our own styles
      org-html-head       "<link rel=\"stylesheet\" href=\"css/tufte.css\" type=\"text/css\" />"
      org-html-head-extra "<link rel=\"stylesheet\" href=\"css/ox-tufte.css\" type=\"text/css\" />"
      org-html-postamble t
      org-html-postamble-format '(("en" "<hr> <p class=\"footer\"> &#8226; A site by Nicky van Foreest &#8226; Generated with %c</p>"))
      )

;; Since both html-head and html-head-extra are used, this is appended to html-extra
;; (setq org-html-head-extra
;;       (concat org-html-head-extra
;;               "<link rel=\"icon\" type=\"image/png\" href=\"img/favicon.ico\" />"))


(setq org-src-preserve-indentation nil
      org-edit-src-content-indentation 0
      org-src-tab-acts-natively t
      org-export-with-smart-quotes t
      org-html-number-lines t
      org-html-link-use-abs-url t
      ;org-html-htmlize-output-type 'inline-css # use 'css and set the colors in ox-tufte.css
      org-html-htmlize-output-type 'css
      org-html-htmlize-font-prefix "org-"
      org-html-use-infojs nil
)

(setq org-publish-project-alist
      (list
       (list "org-site:main"
             :recursive t
             :base-directory "./"
             :publishing-function 'org-tufte-publish-to-html
             :publishing-directory "./public"
             :with-author nil           ;; Don't include author name
             :with-creator t            ;; Include Emacs and Org versions in footer
             :with-toc nil              ;; Include a table of contents
             :section-numbers nil       ;; Don't include section numbers
             :html-preamble (with-temp-buffer
                            (insert-file-contents "preamble.html")
                            (buffer-string))
             :with-title t
             :time-stamp-file nil
             :exclude "\\(?:^drafts/.*\\.org\\|^.packages/.*\\.org\\)"
             :html-html5-fancy t
             :html-doctype "html5"
             :auto-sitemap t
             :sitemap-filename "index.org"
             :sitemap-title "Contents"
             :sitemap-sort-files 'anti-chronologically
             :sitemap-style 'list)))

;; Generate the site output
(org-publish-all t)

(message "Build complete!")
