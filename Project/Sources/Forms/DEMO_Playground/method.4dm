/*
Playground: every knob of the engine, in one form.

Two acts, on the same button:

  Run     each marker flies out with ITS OWN easing, so the twelve curves can be
          compared side by side, over the same distance and the same duration.
          The colour swatches, the property demos and the delayed dots go too.

  Back    every mover is tweened .to() the ElementState captured on load — which
          is also the shortest demo of a keyframe being an ElementState rather
          than a literal.

Note for the reader tempted by heroFrom() here: it would be the wrong tool, and
subtly so. heroFrom() flies objects FROM a snapshot TO where they are now — that
is its whole point across two forms, where the arriving objects already sit at
their natural place. Used here it would snap everything home and then fly it
straight back out again.

All of it lives in the form method on purpose: a class in Classes/ would be
published as cs.hero.Something, and the component's public API is exactly three
classes. A demo has no business in it.
*/

Case of

		//______________________________________________________
	: (Form event code=On Load)

		Form.transition:=cs.ElementTransition.new()

		// Only the things that actually move: capture() takes a list, and there is no
		// point snapshotting panels and labels that never budge
		Form.movers:=[]
		var $n : Integer

		For ($n; 1; 12)
			Form.movers.push("mark_"+String($n))
		End for

		Form.movers.push("swRgb")
		Form.movers.push("swHsv")
		Form.movers.push("pMove")
		Form.movers.push("pSize")
		Form.movers.push("pRadius")
		Form.movers.push("pFont")

		For ($n; 1; 6)
			Form.movers.push("dot_"+String($n))
		End for

		// Their state at rest. This is what "Back" tweens to.
		Form.home:=Form.transition.capture(Form.movers)
		Form.out:=False

		OBJECT SET TITLE(*; "readout"; "12 curves, same distance, same duration.")

		//______________________________________________________
	: (Form event code=On Timer)

		Form.transition.onTimer()

		//______________________________________________________
	: (Form event code=On Clicked)

		If (FORM Event.objectName="buttonRun")

			If (Form.out)

				// ── Act 2: a keyframe can be an ElementState, so the snapshot taken on
				// load IS the destination. No coordinates written anywhere.
				var $home : cs.ElementState

				For each ($home; Form.home)

					// colorMode is a property, not a builder step — it cannot be a
					// function too, 4D will not have both under one name
					var $back : cs.ElementAnimation:=Form.transition.animate($home.name)\
						.to($home)\
						.duration(900)\
						.easing("easeInOutCubic")

					$back.colorMode:="hsv"
					$back.start()

				End for each

				OBJECT SET TITLE(*; "buttonRun"; "Run")
				OBJECT SET TITLE(*; "readout"; "Back home: each keyframe is the ElementState captured on load.")
				OBJECT SET TITLE(*; "code"; "Form.transition.animate($home.name).to($home).duration(900).easing(\"easeInOutCubic\").start()")

			Else

				// ── Act 1: one animation per marker, each with its own curve
				var $easings : Collection:=[\
					"linear"; "easeInQuad"; "easeOutQuad"; "easeInOutQuad"; \
					"easeInCubic"; "easeOutCubic"; "easeInOutCubic"; \
					"easeInBack"; "easeOutBack"; "easeInOutBack"; \
					"easeOutElastic"; "easeOutBounce"\
					]

				var $i : Integer

				For ($i; 1; $easings.length)

					var $track:=cs.ElementState.new("track_"+String($i))
					var $mark:=cs.ElementState.new("mark_"+String($i))

					// .to({left: …}) alone is a move: the width comes along
					Form.transition.animate("mark_"+String($i))\
						.to({left: $track.right-$mark.width})\
						.duration(1200)\
						.easing($easings[$i-1])\
						.start()

				End for

				// ── colorMode: identical endpoints, two different paths through colour
				Form.transition.animate("swRgb")\
					.to({foregroundColor: 0x00C05621; backgroundColor: 0x00FF8C42})\
					.duration(1400)\
					.easing("linear")\
					.start()

				var $hsv : cs.ElementAnimation:=Form.transition.animate("swHsv")\
					.to({foregroundColor: 0x00C05621; backgroundColor: 0x00FF8C42})\
					.duration(1400)\
					.easing("linear")

				$hsv.colorMode:="hsv"
				$hsv.start()

				// ── what an ElementState actually interpolates
				Form.transition.animate("pMove").by(150; 0).duration(1000).easing("easeInOutCubic").start()
				Form.transition.animate("pSize").to({width: 90; height: 44}).duration(1000).easing("easeOutBack").start()
				Form.transition.animate("pRadius").to({cornerRadius: 20}).duration(1000).easing("easeInOutCubic").start()
				Form.transition.animate("pFont").to({fontSize: 26}).duration(1000).easing("easeOutBack").start()

				// ── delay: the same tween six times, started 90 ms apart
				For ($i; 1; 6)

					Form.transition.animate("dot_"+String($i))\
						.by(0; 32)\
						.duration(420)\
						.delay(($i-1)*90)\
						.easing("easeOutBack")\
						.start()

				End for

				OBJECT SET TITLE(*; "buttonRun"; "Back")
				OBJECT SET TITLE(*; "readout"; "Watch the twelve markers: same start, same finish, twelve ways to get there.")
				OBJECT SET TITLE(*; "code"; "Form.transition.animate(\"mark_1\").to({left: 374}).duration(1200).easing(\"easeOutBack\").start()")

			End if

			Form.out:=Not(Form.out)

		End if

		//______________________________________________________
	: (Form event code=On Unload)

		SET TIMER(0)

		//______________________________________________________
End case
