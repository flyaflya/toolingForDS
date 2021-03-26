### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ 1a4a8eb0-7ac2-11eb-2ebe-630b51fdddfa
using Luxor

# ╔═╡ 34c35800-7d13-11eb-05f2-db1789966225
md"""
# Circumscribing Text Within An Ellipse
"""

# ╔═╡ 73e2dbf0-7d13-11eb-0e39-afd2e1884bd4


# ╔═╡ 8d58f4c0-7d13-11eb-0245-150669b7ad2b
@svg begin
	text("Can you see this?")
end

# ╔═╡ 23fcc310-7b80-11eb-2a0b-e1aad1883786
md"""
The below is a function that accepts a text string as input and outputs an ellipse that encloses the text.  I will leave this here as a proof of concept for now, but will seek a more generalizabtle approach.
"""

# ╔═╡ 4984de40-7af6-11eb-1901-d52695df01e1
begin
	## function that accepts a string and bounds it in an ellipse
	function ellipseText(textString, defaultFontSize = 26, defaultFontFace = "Noto-Sans")
		fontsize(defaultFontSize)
		fontface(defaultFontFace)
		arrayVals = textextents(textString)
		textWidth = arrayVals[3,1]
		textHeight = arrayVals[4,1]
		ellipseWidth = 2 * textWidth / sqrt(2)
		ellipseHeight = 2 * (textHeight + 20) / sqrt(2)
		circleRadius = maximum(arrayVals[3:4,1]) / 2 + 10	
		@svg begin
			fontsize(defaultFontSize)
			fontface(defaultFontFace)
			text(textString, halign=:center, valign=:middle)
			ellipse(Point(0, 0), ellipseWidth, ellipseHeight, :stroke)
		end 800 ellipseHeight + 20
	end
end

# ╔═╡ 2a71bd60-7af7-11eb-13bd-45f7f47828ef
## test the function
ellipseText("Are you there? This is a unicode π")

# ╔═╡ 1f443780-7b95-11eb-32db-7bd3864bf71e
begin
	## function that accepts a string and bounds it in an ellipse
	function ellipseText2(textString, action=:stroke, defaultFontSize = 26, defaultFontFace = "Noto-Sans")
		fontsize(defaultFontSize)
		fontface(defaultFontFace)
		arrayVals = textextents(textString)
		ellipseWidth = max(2 * arrayVals[3,1] / sqrt(2) , 80)
		ellipseHeight = max(2 * (arrayVals[4,1] + 20) / sqrt(2),50)
		circleRadius = maximum(arrayVals[3:4,1]) / 2 + 10	
		text(textString, halign=:center, valign=:middle)
		ellipse(Point(0, 0), ellipseWidth, ellipseHeight, :stroke)
	end
end

# ╔═╡ 99db1ef0-7b95-11eb-19f6-454e2c655620
testObject = ellipseText2("test")

# ╔═╡ dea78210-7b97-11eb-360c-877fc084149b
@svg begin
	translate(0,-120)
	ellipseText2("test")
	arrow(Point(0, 30), Point(0, 90))
	translate(0,120)
	ellipseText2("testItSomeMore")
	arrow(Point(0, 30), Point(0, 90))
	translate(0,120)
	ellipseText2("Extra Stuff")
end 800 400


# ╔═╡ Cell order:
# ╠═1a4a8eb0-7ac2-11eb-2ebe-630b51fdddfa
# ╟─34c35800-7d13-11eb-05f2-db1789966225
# ╠═73e2dbf0-7d13-11eb-0e39-afd2e1884bd4
# ╠═8d58f4c0-7d13-11eb-0245-150669b7ad2b
# ╟─23fcc310-7b80-11eb-2a0b-e1aad1883786
# ╠═4984de40-7af6-11eb-1901-d52695df01e1
# ╟─2a71bd60-7af7-11eb-13bd-45f7f47828ef
# ╠═1f443780-7b95-11eb-32db-7bd3864bf71e
# ╠═99db1ef0-7b95-11eb-19f6-454e2c655620
# ╠═dea78210-7b97-11eb-360c-877fc084149b
