(function () {
  "use strict";

  /* Collapsible sidebar — a single "nav-collapsed" class on <body>
     hides it and gives the content its width back, at any screen size */
  var navToggle = document.getElementById("navToggle");
  var navLinks = document.getElementById("navLinks");

  function setNavOpen(isOpen) {
    document.body.classList.toggle("nav-collapsed", !isOpen);
    if (navToggle) {
      navToggle.classList.toggle("open", isOpen);
      navToggle.setAttribute("aria-expanded", String(isOpen));
    }
    /* the sidebar's width change shifts how the hero content centers —
       track any still-unmoved decorative notes alongside it in real time
       for the full length of the collapse/expand transition (0.35s),
       instead of snapping them into place once it's over */
    if (typeof animateDecorativeReposition === "function") {
      animateDecorativeReposition(400);
    }
  }

  if (navToggle) {
    /* starts collapsed on narrow/mobile screens, open on desktop */
    setNavOpen(window.innerWidth > 720);

    navToggle.addEventListener("click", function () {
      setNavOpen(document.body.classList.contains("nav-collapsed"));
    });

    if (navLinks && window.matchMedia("(max-width: 720px)").matches) {
      navLinks.querySelectorAll(".nav-link").forEach(function (link) {
        link.addEventListener("click", function () {
          setNavOpen(false);
        });
      });
    }
  }

  /* Typewriter hero name — retypes every time someone navigates back to the top */
  var typedNameEl = document.getElementById("typedName");
  var typedCursorEl = document.getElementById("typedCursor");
  var prefersReducedMotion = window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  var nameTypeTimer = null;

  function startNameTyping() {
    if (!typedNameEl) return;
    var fullName = "Kore Omodara";

    clearInterval(nameTypeTimer);

    if (prefersReducedMotion) {
      typedNameEl.textContent = fullName;
      if (typedCursorEl) typedCursorEl.classList.add("done");
      return;
    }

    typedNameEl.textContent = "";
    if (typedCursorEl) typedCursorEl.classList.remove("done");

    var charIndex = 0;
    nameTypeTimer = setInterval(function () {
      charIndex++;
      typedNameEl.textContent = fullName.slice(0, charIndex);
      if (charIndex >= fullName.length) {
        clearInterval(nameTypeTimer);
        setTimeout(function () {
          if (typedCursorEl) typedCursorEl.classList.add("done");
        }, 1300);
      }
    }, 90);
  }

  startNameTyping();

  /* Retype whenever a nav link takes the visitor back to the top of the page */
  document.querySelectorAll('a[href="#top"], a[href$="index.html#top"]').forEach(function (link) {
    link.addEventListener("click", function () {
      startNameTyping();
    });
  });

  /* Rotating role title: Product Designer <-> UX Designer */
  var roleTypedEl = document.getElementById("roleTyped");
  var roleCursorEl = document.getElementById("roleCursor");
  var roleKickerEl = document.getElementById("roleKicker");

  if (roleTypedEl) {
    var roles = ["Product Designer", "UX Designer", "Problem Solver"];

    if (prefersReducedMotion) {
      roleTypedEl.textContent = roles.join(" · ");
      if (roleCursorEl) roleCursorEl.style.display = "none";
    } else {
      (function cycleRoles() {
        var roleIndex = 0;
        var charIndex = 0;
        var deleting = false;
        var paused = false;
        var timer;

        function tick() {
          if (paused) {
            timer = setTimeout(tick, 150);
            return;
          }

          var word = roles[roleIndex];

          if (!deleting) {
            charIndex++;
            roleTypedEl.textContent = word.slice(0, charIndex);
            if (charIndex === word.length) {
              deleting = true;
              timer = setTimeout(tick, 1500);
            } else {
              timer = setTimeout(tick, 70);
            }
          } else {
            charIndex--;
            roleTypedEl.textContent = word.slice(0, charIndex);
            if (charIndex === 0) {
              deleting = false;
              roleIndex = (roleIndex + 1) % roles.length;
              timer = setTimeout(tick, 350);
            } else {
              timer = setTimeout(tick, 40);
            }
          }
        }

        timer = setTimeout(tick, 500);

        if (roleKickerEl) {
          roleKickerEl.addEventListener("mouseenter", function () { paused = true; });
          roleKickerEl.addEventListener("mouseleave", function () { paused = false; });
        }
      })();
    }
  }

  /* Sticky notes: grab one and stick it anywhere else on the page — as
     many times as you like, but never on top of readable text. */
  var TEXT_SELECTOR =
    "p, h1, h2, h3, li, a, .tag, .eyebrow, .btn-primary, .nav-link, " +
    ".skill-chips li, .case-title, .case-tagline, .stat";

  function rectsOverlap(a, b) {
    return !(
      a.right <= b.left ||
      a.left >= b.right ||
      a.bottom <= b.top ||
      a.top >= b.bottom
    );
  }

  function overlapsText(note) {
    var noteRect = note.getBoundingClientRect();
    var candidates = document.querySelectorAll(TEXT_SELECTOR);
    for (var i = 0; i < candidates.length; i++) {
      var el = candidates[i];
      if (note.contains(el) || el.contains(note)) continue;
      var text = (el.textContent || "").trim();
      if (!text) continue;
      if (rectsOverlap(noteRect, el.getBoundingClientRect())) return true;
    }
    return false;
  }

  document.querySelectorAll(".sticky-note:not(.static-sticky)").forEach(function (note) {
    /* the note's true original spot, so "snap back" always works no
       matter how many times it's been picked up and dropped before */
    var homeParent = note.parentNode;
    var homeNext = note.nextSibling;

    var placeholder = null;
    var grabOffsetX = 0;
    var grabOffsetY = 0;
    var moved = false;
    var startClientX = 0;
    var startClientY = 0;

    function returnHome() {
      note.style.position = "";
      note.style.left = "";
      note.style.top = "";
      note.style.margin = "";
      if (homeNext && homeNext.parentNode === homeParent) {
        homeParent.insertBefore(note, homeNext);
      } else {
        homeParent.appendChild(note);
      }
    }

    function onPointerMove(e) {
      var dx = e.clientX - startClientX;
      var dy = e.clientY - startClientY;
      if (!moved && (Math.abs(dx) > 4 || Math.abs(dy) > 4)) {
        moved = true;
        note.classList.add("dragging");
      }
      if (!moved) return;

      var rect = note.getBoundingClientRect();
      var maxLeft = document.documentElement.clientWidth - rect.width;
      var maxTop = document.documentElement.scrollHeight - rect.height;

      var left = e.clientX - grabOffsetX + window.scrollX;
      var top = e.clientY - grabOffsetY + window.scrollY;

      left = Math.max(0, Math.min(left, maxLeft));
      top = Math.max(0, Math.min(top, maxTop));

      note.style.left = left + "px";
      note.style.top = top + "px";
    }

    function onPointerUp(e) {
      note.removeEventListener("pointermove", onPointerMove);
      note.classList.remove("dragging");
      try {
        note.releasePointerCapture(e.pointerId);
      } catch (err) {
        /* already released or never captured — nothing to do */
      }

      if (placeholder && placeholder.parentNode) placeholder.remove();
      placeholder = null;

      if (!moved) {
        /* simple click/tap with no drag — put it back exactly as it was */
        returnHome();
        return;
      }

      if (overlapsText(note)) {
        /* would cover real content — reject the drop and snap back */
        returnHome();
        note.classList.add("rejected");
        setTimeout(function () {
          note.classList.remove("rejected");
        }, 400);
        return;
      }

      /* dropped cleanly on open board space: leave it stuck there */
      note.classList.add("dropped");
      setTimeout(function () {
        note.classList.remove("dropped");
      }, 420);
    }

    note.addEventListener("pointerdown", function (e) {
      if (e.button !== undefined && e.button !== 0) return;
      if (e.target.closest("a")) return; /* let links inside notes work normally */

      moved = false;
      startClientX = e.clientX;
      startClientY = e.clientY;

      var rect = note.getBoundingClientRect();
      grabOffsetX = e.clientX - rect.left;
      grabOffsetY = e.clientY - rect.top;

      placeholder = document.createElement("div");
      placeholder.className = "sticky-note-slot";
      placeholder.style.width = rect.width + "px";
      placeholder.style.height = rect.height + "px";
      note.parentNode.insertBefore(placeholder, note);

      document.body.appendChild(note);
      note.style.position = "absolute";
      note.style.margin = "0";
      note.style.left = (rect.left + window.scrollX) + "px";
      note.style.top = (rect.top + window.scrollY) + "px";

      note.addEventListener("pointermove", onPointerMove);
      try {
        note.setPointerCapture(e.pointerId);
      } catch (err) {
        /* pointer capture unsupported/unavailable — dragging still
           works via the regular pointermove listener above */
      }
    });

    note.addEventListener("pointerup", onPointerUp);
    note.addEventListener("pointercancel", onPointerUp);
  });

  /* Contact: copy email as a backup alongside the mailto link */
  var contactEmailBtn = document.getElementById("contactEmailBtn");
  var copyEmailBtn = document.getElementById("copyEmailBtn");
  var emailAddress = "koreomodara@gmail.com";

  if (contactEmailBtn) {
    contactEmailBtn.addEventListener("click", function () {
      /* let the mailto: navigation proceed as normal; this is just a
         safety net in case the visitor has no mail client configured */
      copyLinkSilently(emailAddress);
    });
  }

  if (copyEmailBtn) {
    copyEmailBtn.addEventListener("click", function () {
      copyLink(emailAddress, "Email copied to clipboard");
    });
  }

  /* Scroll reveal */
  var revealEls = document.querySelectorAll(".reveal");

  if ("IntersectionObserver" in window) {
    var revealObserver = new IntersectionObserver(
      function (entries) {
        entries.forEach(function (entry) {
          if (entry.isIntersecting) {
            entry.target.classList.add("in-view");
            revealObserver.unobserve(entry.target);
          }
        });
      },
      { threshold: 0.15, rootMargin: "0px 0px -40px 0px" }
    );

    revealEls.forEach(function (el) {
      revealObserver.observe(el);
    });
  } else {
    revealEls.forEach(function (el) {
      el.classList.add("in-view");
    });
  }

  /* Active nav link on scroll */
  var sections = document.querySelectorAll("main section[id]");
  var navLinkEls = document.querySelectorAll(".nav-link");

  if ("IntersectionObserver" in window && sections.length) {
    var navObserver = new IntersectionObserver(
      function (entries) {
        entries.forEach(function (entry) {
          var id = entry.target.getAttribute("id");
          var matchingLink = document.querySelector('.nav-link[data-section="' + id + '"]');
          if (!matchingLink) return;

          if (entry.isIntersecting) {
            navLinkEls.forEach(function (l) { l.classList.remove("active"); });
            matchingLink.classList.add("active");
          }
        });
      },
      { rootMargin: "-45% 0px -45% 0px", threshold: 0 }
    );

    sections.forEach(function (section) {
      if (section.id) navObserver.observe(section);
    });
  }

  /* Pinterest-style card actions: pin (save), like, share */
  function showToast(message) {
    var toast = document.getElementById("toast");
    if (!toast) {
      toast = document.createElement("div");
      toast.id = "toast";
      toast.className = "toast";
      document.body.appendChild(toast);
    }
    toast.textContent = message;
    toast.classList.add("show");
    clearTimeout(showToast._timer);
    showToast._timer = setTimeout(function () {
      toast.classList.remove("show");
    }, 2200);
  }

  function fallbackCopy(text) {
    var textarea = document.createElement("textarea");
    textarea.value = text;
    textarea.style.position = "fixed";
    textarea.style.opacity = "0";
    document.body.appendChild(textarea);
    textarea.focus();
    textarea.select();
    try {
      document.execCommand("copy");
    } catch (err) {
      /* clipboard unavailable; nothing more we can do */
    }
    document.body.removeChild(textarea);
  }

  function copyLinkSilently(text) {
    if (navigator.clipboard && window.isSecureContext) {
      navigator.clipboard.writeText(text).catch(function () {
        fallbackCopy(text);
      });
    } else {
      fallbackCopy(text);
    }
  }

  function copyLink(text, message) {
    copyLinkSilently(text);
    showToast(message || "Link copied to clipboard");
  }

  /* Which side each card's arc opens toward: left-column cards fan out
     left, right-column cards fan out right, so the arc always points
     away from the gutter between columns instead of into it. */
  function updateArcDirections() {
    var masonry = document.querySelector(".masonry");
    if (!masonry) return;
    var centerX = masonry.getBoundingClientRect().left + masonry.getBoundingClientRect().width / 2;

    document.querySelectorAll(".project-card").forEach(function (card) {
      var cardCenterX = card.getBoundingClientRect().left + card.getBoundingClientRect().width / 2;
      card.classList.toggle("arc-right", cardCenterX >= centerX);
    });
  }

  updateArcDirections();
  window.addEventListener("load", updateArcDirections);

  var arcResizeTimer = null;
  window.addEventListener("resize", function () {
    clearTimeout(arcResizeTimer);
    arcResizeTimer = setTimeout(updateArcDirections, 150);
  });

  document.querySelectorAll(".project-card").forEach(function (card) {
    var projectId = card.dataset.project;
    var caseUrl = card.dataset.caseUrl;
    var titleEl = card.querySelector(".project-title");
    var title = titleEl ? titleEl.textContent.trim() : "this project";

    var pinBtn = card.querySelector(".pin-btn");
    var likeBtn = card.querySelector(".like-btn");
    var shareBtn = card.querySelector(".share-btn");

    /* Whole card navigates to the case study; the fan controls stop
       propagation below so they never trigger this. */
    if (caseUrl) {
      card.addEventListener("click", function () {
        window.location.href = caseUrl;
      });
    }

    if (pinBtn) {
      if (localStorage.getItem("pinned-" + projectId) === "1") {
        pinBtn.classList.add("active");
        pinBtn.setAttribute("aria-pressed", "true");
      }
      pinBtn.addEventListener("click", function (e) {
        e.preventDefault();
        e.stopPropagation();
        var active = pinBtn.classList.toggle("active");
        pinBtn.setAttribute("aria-pressed", String(active));
        localStorage.setItem("pinned-" + projectId, active ? "1" : "0");
      });
    }

    if (likeBtn) {
      if (localStorage.getItem("liked-" + projectId) === "1") {
        likeBtn.classList.add("active");
        likeBtn.setAttribute("aria-pressed", "true");
      }
      likeBtn.addEventListener("click", function (e) {
        e.preventDefault();
        e.stopPropagation();
        var active = likeBtn.classList.toggle("active");
        likeBtn.setAttribute("aria-pressed", String(active));
        localStorage.setItem("liked-" + projectId, active ? "1" : "0");
      });
    }

    if (shareBtn) {
      shareBtn.addEventListener("click", function (e) {
        e.preventDefault();
        e.stopPropagation();

        var absoluteUrl;
        try {
          absoluteUrl = new URL(caseUrl, window.location.href).href;
        } catch (err) {
          absoluteUrl = caseUrl;
        }

        var shareData = {
          title: "Kore Omodara — " + title,
          text: "Check out " + title + " by Kore Omodara.",
          url: absoluteUrl
        };

        /* The Web Share API rejects (or on some browsers, throws
           synchronously) for file:// URLs, so skip straight to the
           clipboard fallback when running from a local file. */
        var canNativeShare = navigator.share && window.location.protocol !== "file:";

        if (canNativeShare) {
          try {
            navigator.share(shareData).catch(function (err) {
              if (err && err.name !== "AbortError") {
                copyLink(absoluteUrl);
              }
            });
          } catch (err) {
            copyLink(absoluteUrl);
          }
        } else {
          copyLink(absoluteUrl);
        }
      });
    }
  });

  /* Sticky nav background intensifies after scrolling past hero */
  var siteNav = document.getElementById("siteNav");
  var lastKnownState = false;

  function updateNavState() {
    var scrolled = window.scrollY > 40;
    if (scrolled !== lastKnownState) {
      siteNav.classList.toggle("scrolled", scrolled);
      lastKnownState = scrolled;
    }
  }

  if (siteNav) {
    window.addEventListener("scroll", updateNavState, { passive: true });
    updateNavState();
  }

  /* Fun quirk: let visitors pin their own sticky note — cycles
     yellow -> pink -> blue, editable inline, gone on refresh */
  var noteColors = ["sticky-yellow", "sticky-pink", "sticky-blue"];
  var noteColorIndex = 0;
  var noteSpawnCount = 0;

  var addNoteBtn = document.createElement("button");
  addNoteBtn.type = "button";
  addNoteBtn.className = "add-note-btn";
  addNoteBtn.setAttribute("aria-label", "Add a sticky note");
  addNoteBtn.title = "Add a sticky note";
  addNoteBtn.innerHTML =
    '<svg viewBox="0 0 24 24" fill="none"><path d="M12 5v14M5 12h14" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>';
  document.body.appendChild(addNoteBtn);
  addNoteBtn.addEventListener("click", createUserNote);

  /* Searches outward in a ring pattern from a note's current spot for
     the nearest position that doesn't sit on top of real text/content */
  function findFreeSpot(note) {
    var rect = note.getBoundingClientRect();
    var startLeft = parseFloat(note.style.left) || rect.left + window.scrollX;
    var startTop = parseFloat(note.style.top) || rect.top + window.scrollY;
    var maxLeft = document.documentElement.clientWidth - rect.width - 10;
    var maxTop = document.documentElement.scrollHeight - rect.height - 10;

    var directions = [
      [1, 0], [0, 1], [-1, 0], [0, -1],
      [1, 1], [-1, 1], [1, -1], [-1, -1]
    ];

    for (var radius = 40; radius <= 480; radius += 40) {
      for (var i = 0; i < directions.length; i++) {
        var left = Math.max(10, Math.min(startLeft + directions[i][0] * radius, maxLeft));
        var top = Math.max(10, Math.min(startTop + directions[i][1] * radius, maxTop));

        note.style.left = left + "px";
        note.style.top = top + "px";

        if (!overlapsText(note)) {
          return { left: left, top: top };
        }
      }
    }

    return { left: startLeft, top: startTop };
  }

  function buildUserNote(color, rotationDeg) {
    var note = document.createElement("div");
    note.className = "sticky-note user-sticky " + color;
    note.style.setProperty("--base-rot", rotationDeg.toFixed(1) + "deg");

    var closeBtn = document.createElement("button");
    closeBtn.type = "button";
    closeBtn.className = "user-sticky-close";
    closeBtn.setAttribute("aria-label", "Remove note");
    closeBtn.innerHTML = "&times;";
    closeBtn.addEventListener("pointerdown", function (e) {
      e.stopPropagation();
    });
    closeBtn.addEventListener("click", function (e) {
      e.stopPropagation();
      note.remove();
    });

    var text = document.createElement("div");
    text.className = "user-sticky-text";
    text.contentEditable = "true";
    text.setAttribute("data-placeholder", "Type something…");

    note.appendChild(closeBtn);
    note.appendChild(text);
    note.style.position = "absolute";

    setupUserNoteDrag(note);

    return { note: note, text: text };
  }

  function createUserNote() {
    var color = noteColors[noteColorIndex % noteColors.length];
    noteColorIndex++;
    var built = buildUserNote(color, Math.random() * 10 - 5);
    document.body.appendChild(built.note);

    noteSpawnCount++;
    var jitter = (noteSpawnCount % 5) * 16;
    var left = Math.max(20, window.innerWidth / 2 - 120 + jitter) + window.scrollX;
    var top = Math.max(90, window.innerHeight / 2 - 110 + jitter) + window.scrollY;
    built.note.style.left = left + "px";
    built.note.style.top = top + "px";

    requestAnimationFrame(function () {
      built.text.focus();
    });
  }

  /* A handful of blank "plank" notes scattered around the hero at load,
     so the landing reads as messier/more lived-in right away. Anchored
     to the hero content's own measured edges (not a guessed viewport
     percentage), so they stay correctly clear of it whether the sidebar
     is open or collapsed — right up until a visitor drags one themself. */
  var decorativeSpots = [
    { color: "sticky-yellow", rot: -4, anchor: "left", topOffset: -40, gap: 55 },
    /* deliberately pushed above the hero content so its top edge is
       cropped by the viewport on load — a note pinned just out of frame */
    { color: "sticky-pink", rot: 3, anchor: "right", topOffset: -215, gap: 40 },
    { color: "sticky-blue", rot: 5, anchor: "left", topOffset: 260, gap: 65 }
  ];
  var decorativeNotes = [];

  function positionDecorativeNote(entry) {
    var heroInner = document.querySelector(".hero-inner");
    if (!heroInner) return;

    var heroRect = heroInner.getBoundingClientRect();
    var noteRect = entry.note.getBoundingClientRect();
    var left;

    if (entry.spot.anchor === "right") {
      left = heroRect.right + entry.spot.gap;
    } else {
      left = heroRect.left - noteRect.width - entry.spot.gap;
    }

    left = Math.max(16, left) + window.scrollX;
    var top = heroRect.top + entry.spot.topOffset + window.scrollY;

    entry.note.style.left = left + "px";
    entry.note.style.top = top + "px";
  }

  function spawnDecorativeNotes() {
    decorativeSpots.forEach(function (spot) {
      var built = buildUserNote(spot.color, spot.rot);
      built.note.dataset.autoPositioned = "true";
      document.body.appendChild(built.note);

      var entry = { note: built.note, spot: spot };
      decorativeNotes.push(entry);
      positionDecorativeNote(entry);
    });
  }

  function repositionDecorativeNotes() {
    (decorativeNotes || []).forEach(function (entry) {
      if (entry.note.dataset.autoPositioned === "true") {
        positionDecorativeNote(entry);
      }
    });
  }

  /* Follows the hero content's actual position every frame for `duration`
     ms, so decorative notes glide along with the sidebar's collapse/expand
     transition instead of jumping to their new spot once it's done. */
  function animateDecorativeReposition(duration) {
    var start = performance.now();
    function step(now) {
      repositionDecorativeNotes();
      if (now - start < duration) {
        requestAnimationFrame(step);
      }
    }
    requestAnimationFrame(step);
  }

  spawnDecorativeNotes();

  var decorativeResizeTimer = null;
  window.addEventListener("resize", function () {
    clearTimeout(decorativeResizeTimer);
    decorativeResizeTimer = setTimeout(repositionDecorativeNotes, 150);
  });

  function setupUserNoteDrag(note) {
    var grabOffsetX = 0;
    var grabOffsetY = 0;
    var moved = false;
    var startClientX = 0;
    var startClientY = 0;
    var lastLeft = parseFloat(note.style.left) || 0;
    var lastTop = parseFloat(note.style.top) || 0;

    function onPointerMove(e) {
      var dx = e.clientX - startClientX;
      var dy = e.clientY - startClientY;
      if (!moved && (Math.abs(dx) > 4 || Math.abs(dy) > 4)) {
        moved = true;
        note.classList.add("dragging");
      }
      if (!moved) return;

      note.style.left = (e.clientX - grabOffsetX + window.scrollX) + "px";
      note.style.top = (e.clientY - grabOffsetY + window.scrollY) + "px";
    }

    function onPointerUp(e) {
      note.removeEventListener("pointermove", onPointerMove);
      note.classList.remove("dragging");
      try {
        note.releasePointerCapture(e.pointerId);
      } catch (err) {
        /* already released or never captured — nothing to do */
      }

      if (!moved) return;

      /* once a visitor actually moves it, it's no longer auto-repositioned
         when the sidebar opens/collapses — it stays wherever they put it */
      delete note.dataset.autoPositioned;

      if (overlapsText(note)) {
        /* can't sit on top of real content — hop to the nearest open spot
           instead of just snapping back, so it always finds a home */
        var freeSpot = findFreeSpot(note);
        note.style.left = freeSpot.left + "px";
        note.style.top = freeSpot.top + "px";
      }

      lastLeft = parseFloat(note.style.left) || 0;
      lastTop = parseFloat(note.style.top) || 0;
      note.classList.add("dropped");
      setTimeout(function () {
        note.classList.remove("dropped");
      }, 420);
    }

    note.addEventListener("pointerdown", function (e) {
      if (e.button !== undefined && e.button !== 0) return;
      if (e.target.closest(".user-sticky-text") || e.target.closest(".user-sticky-close")) return;

      moved = false;
      startClientX = e.clientX;
      startClientY = e.clientY;

      var rect = note.getBoundingClientRect();
      grabOffsetX = e.clientX - rect.left;
      grabOffsetY = e.clientY - rect.top;

      note.addEventListener("pointermove", onPointerMove);
      try {
        note.setPointerCapture(e.pointerId);
      } catch (err) {
        /* pointer capture unsupported/unavailable — dragging still
           works via the regular pointermove listener above */
      }
    });

    note.addEventListener("pointerup", onPointerUp);
    note.addEventListener("pointercancel", onPointerUp);
  }
})();
