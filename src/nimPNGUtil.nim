import nimPNG, strutils

type
  Image* = object
    width*: int
    height*: int
    data*: string

proc newImage*(width, height: int): Image =
  Image(width: width, height: height, data: newString(width * height * 3))

proc newImage*(width, height: int; color: int): Image =
  let c = char(color shr 16) & char(color shr 8) & char(color)
  Image(width: width, height: height, data: c.repeat(width * height))

proc setPixel*(img: var Image; x, y: int; color: int) =
  assert x >= 0 and x < img.width
  assert y >= 0 and y < img.height
  assert img.data.len != 0

  let p = (x + y * img.width) * 3
  var c = color
  for i in 0..2:
    img.data[p + 2 - i] = char(c and 0xff)
    c = c shr 8

proc setPixel*(img: var Image; x, y: int; color: uint8) =
  assert x >= 0 and x < img.width
  assert y >= 0 and y < img.height
  assert img.data.len != 0

  let p = (x + y * img.width) * 3
  for i in 0..2:
    img.data[p + i] = cast[char](color)

proc save*(img: Image; filename: string): bool =
  savePNG24(filename, img.data, img.width, img.height)

# Delay = delayNum / delayDen seconds
proc newAPNGFrameControl*(img: Image; delayNum, delayDen: int): APNGFrameControl =
  result = new(APNGFrameControl)
  result.width = img.width
  result.height = img.height
  result.xOffset = 0
  result.yOffset = 0
  result.delayNum = delayNum
  result.delayDen = delayDen
  result.disposeOp = APNG_DISPOSE_OP_NONE
  result.blendOp = APNG_BLEND_OP_SOURCE

proc addDefaultImage*(
                    png: PNG;
                    img: Image;
                    delayNum, delayDen: int) =
  doAssert png.addDefaultImage(
                              img.data,
                              img.width, img.height,
                              newAPNGFrameControl(img, delayNum, delayDen))

proc addFrame*(png: PNG; img: Image; delayNum, delayDen: int) =
  doAssert png.addFrame(img.data, newAPNGFrameControl(img, delayNum, delayDen))
