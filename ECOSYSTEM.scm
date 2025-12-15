;; SPDX-License-Identifier: AGPL-3.0-or-later
;; SPDX-FileCopyrightText: 2025 Jonathan D.A. Jewell
;; ECOSYSTEM.scm — elegant-state

(ecosystem
  (version "1.0.0")
  (name "elegant-state")
  (type "project")
  (purpose "Local-first state graph for multi-agent orchestration.")

  (position-in-ecosystem
    "Part of hyperpolymath ecosystem. Follows RSR guidelines.")

  (related-projects
    (project (name "rhodium-standard-repositories")
             (url "https://github.com/hyperpolymath/rhodium-standard-repositories")
             (relationship "standard")))

  (what-this-is "Local-first state graph for multi-agent orchestration.")
  (what-this-is-not "- NOT exempt from RSR compliance"))
