;;; helm-kaomoji.el --- helm for kaomoji

;; Copyright (C) 2014 by Syohei YOSHIDA

;; Author: Syohei YOSHIDA <syohex@gmail.com>
;; URL:
;; Version: 0.01

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;; Code:

(require 'helm)

(defconst helm-kaomoji--url "http://kaosute.net/jisyo/pdf2.cgi?file=2ch_ver1&method=download")

(defun helm-kaomoji--candidates ()
  (with-temp-buffer
    (let ((coding-system-for-read 'binary)
          (coding-system-for-write 'binary))
      (unless (zerop (call-process "curl" nil t nil "-s" helm-kaomoji--url))
        (error "Can't download kaomoji file"))
      (decode-coding-region (point-min) (point-max) 'cp932)
      (goto-char (point-min)))
    (let (kaomojis)
      (while (not (eobp))
        (let ((line (buffer-substring-no-properties
                     (line-beginning-position) (line-end-position))))
          (unless (string-match-p "\\`\\(?:!\\|かおすて\\)" line)
            (let ((columns (split-string line "\t")))
              (push (nth 1 columns) kaomojis))))
        (forward-line 1))
      (reverse kaomojis))))

(defvar helm-kaomoji--source
  '((name . "Helm Kaomoji")
    (candidates . helm-kaomoji--candidates)
    (candidates-number-limit . 9999)
    (action . (("Insert" . insert)
               ("Show kaomoji" . message)))))

;;;###autoload
(defun helm-kaomoji ()
  (interactive)
  (helm :sources '(helm-kaomoji--source) :buffer "*helm-kaomoji*"))

(provide 'helm-kaomoji)

;;; helm-kaomoji.el ends here
