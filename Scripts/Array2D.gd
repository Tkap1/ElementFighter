extends Node

var array = []
var size

func _init(size, funcRef):
    self.size = size
    for x in size.x:
        array.append([])
        for y in size.y:
            array[x].append(funcRef.call_func(Vector2(x,y)))
            
func getElement(index):
    return array[index.x][index.y]
    
func getRandomElement():
    return getElement(getRandomIndex())
    
func getRandomIndex():
    var x = randi() % int(size.x)
    var y = randi() % int(size.y)
    return Vector2(x,y)
    
func isValidIndex(index):
    if index.x in range(size.x) and index.y in range(size.y):
        return true
    return false
    
func getIndex(element):
    for y in size.y:
        for x in size.x:
            if array[x][y] == element:
                return Vector2(x,y)
    return null
    
func removeAtIndex(index, freeTheElement=false):
    if isValidIndex(index):
        if freeTheElement:
            array[index.x][index.y].queue_free()
        array[index.x][index.y] = null
        
func removeElement(element, freeTheElement=false):
    var index = getIndex(element)
    if index != null:
        if freeTheElement:
            array[index.x][index.y].queue_free()
        array[index.x][index.y] = null
  
# If the given index is valid, returns the same index, otherwise, returns a new index that wraps around the edges
# For example, if size.x is 10 and index.x is 10, the new index returned would have .x = 0
func wrapAround(index):
    var newX = index.x
    var newY = index.y
    if index.x >= size.x:
        newX = 0
    elif index.x < 0:
        newX = size.x - 1
        
    if index.y >= size.y:
        newY = 0
    elif index.y < 0:
        newY = size.y - 1
        
    return Vector2(newX,newY)
    

# Returns the index that the current mouse position translates to
func getMouseIndex(source, pixelSize):
    var mouse = source.get_global_mouse_position()
    var x = int(mouse.x) / int(pixelSize.x)
    var y = int(mouse.y) / int(pixelSize.y)
    return Vector2(x,y)
    
# Returns the element that the current mouse position translates to
func getMouseElement(source, pixelSize):
    var index = getMouseIndex(source, pixelSize)
    if isValidIndex(index):
        return getElement(index)
    return null
    
# Returns an array containing the elements 1 index to the left, right, up and down
func getAdjacent4(sourceElement):
    var offsets = [Vector2(-1,0),Vector2(1,0),Vector2(0,-1),Vector2(0,1)]
    var baseIndex = getIndex(sourceElement)
    var adjacentElements = []
    for offset in offsets:
        var newIndex = baseIndex + offset
        if isValidIndex(newIndex):
            adjacentElements.append(getElement(newIndex))
    return adjacentElements
        
# Returns an array containing the elements 1 index to the topleft, middletop, topright, middleleft, middleright, bottomleft, middlebottom, bottomright 
func getAdjacent8(sourceElement):
    var offsets = [Vector2(-1,-1),Vector2(0,-1),Vector2(1,-1),Vector2(-1,0),Vector2(1,0),Vector2(-1,1),Vector2(0,1),Vector2(1,1)]
    var baseIndex = getIndex(sourceElement)
    var adjacentElements = []
    for offset in offsets:
        var newIndex = baseIndex + offset
        if isValidIndex(newIndex):
            adjacentElements.append(getElement(newIndex))
    return adjacentElements
        
    
        
    
    