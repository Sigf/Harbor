class_name ConstructionGrid extends Node3D
# Generates a 2D grid projected to a 3D landscape. Can return the nearest grid cell given a 3D location.
# Uses sub grids to recursively find the nearest cell without iterating over every cells

@export var grid_quadrants_size: int = 16
@export var grid_quadrants_x: int = 2
@export var grid_quadrants_y: int = 2
@export var sub_grid_divisions: int = 4

@export var available_color: Color
@export var invalid_placement_color: Color
@export var selected_color: Color

@onready var grid_mesh: Mesh = load("res://World/ConstructionGrid/Meshes/ConstructionGridTile_Mesh.obj")
@onready var grid_material: ShaderMaterial = load("res://World/ConstructionGrid/Materials/ConstructionGridCell_Material.tres")

var cursor_position: Vector3
var grid_cells: Array[Cell] = []
var multimesh_rid: RID
var grid_instance_rid: RID

enum CellState {AVAILABLE, SELECTED, INVALID}

class Cell:
    var size: int
    var origin: Vector3
    var grid_index: int
    var neighbor_cells: Array[Cell] # 0:left, 1:right, 2:up, 3:down
    var sub_grid: Cell
    var transform: Transform3D
    var state: CellState = CellState.AVAILABLE
    var buffer: PackedFloat32Array

    static var available_color: Color = Color(0.0, 0.0, 1.0)
    static var selected_color: Color = Color(0.0, 1.0, 0.0)
    static var invalid_color: Color = Color(1.0, 0.0, 0.0)

    func _init(in_size: int, in_origin: Vector3, in_grid_index: int) -> void:
        self.size = in_size
        self.origin = in_origin
        self.grid_index = in_grid_index
        self.neighbor_cells = []
        self.sub_grid = null

        self.transform = Transform3D.IDENTITY
        self.transform.origin = in_origin
        self.buffer = [
            # 12 floats representing the transform matrix
            self.transform.basis.x.x,
            self.transform.basis.y.x,
            self.transform.basis.z.x,
            self.transform.origin.x,
            self.transform.basis.x.y,
            self.transform.basis.y.y,
            self.transform.basis.z.y,
            self.transform.origin.y,
            self.transform.basis.x.z,
            self.transform.basis.y.z,
            self.transform.basis.z.z,
            self.transform.origin.z,
            # 4 floats for color RGBA, default is the "available" color
            available_color.r,
            available_color.g,
            available_color.b,
            1.0
        ]

    func inside_cell(position: Vector3) -> bool:
        return position.x >= origin.x and position.x < origin.x + size and position.z >= origin.z and position.z < origin.z + size
    
    # Check if the cursor is inside the cell, and update its state if needed. Returns true if the cell state was changed.
    func test_cursor_position(position: Vector3) -> bool:
        if inside_cell(position) and self.state != CellState.SELECTED:
            self.state = CellState.SELECTED
            update_buffer()
            return true
        
        if not inside_cell(position) and self.state != CellState.AVAILABLE:
            self.state = CellState.AVAILABLE
            update_buffer()
            return true
        
        return false

    func update_buffer() -> void:
        # Update the buffer with the current transform and color based on state
        self.buffer[0] = self.transform.basis.x.x
        self.buffer[1] = self.transform.basis.y.x
        self.buffer[2] = self.transform.basis.z.x
        self.buffer[3] = self.transform.origin.x
        self.buffer[4] = self.transform.basis.x.y
        self.buffer[5] = self.transform.basis.y.y
        self.buffer[6] = self.transform.basis.z.y
        self.buffer[7] = self.transform.origin.y
        self.buffer[8] = self.transform.basis.x.z
        self.buffer[9] = self.transform.basis.y.z
        self.buffer[10] = self.transform.basis.z.z
        self.buffer[11] = self.transform.origin.z

        var color: Color = available_color
        match self.state:
            CellState.AVAILABLE:
                color = available_color
            CellState.SELECTED:
                color = selected_color
            CellState.INVALID:
                color = invalid_color

        self.buffer[12] = color.r
        self.buffer[13] = color.g
        self.buffer[14] = color.b
        self.buffer[15] = 1.0


func generate_test_grid() -> void:
    assert(multimesh_rid.is_valid())
    # Generate a test grid for visualization in the editor

    # var multimesh: MultiMesh = grid_instance_mesh.multimesh
    # multimesh.instance_count = grid_quadrants_x * grid_quadrants_y
    # multimesh.visible_instance_count = multimesh.instance_count

    var cell_count: int = grid_quadrants_x * grid_quadrants_y

    var origin: Vector3 = global_transform.origin;
    for i in cell_count:
        var x_index: int = i % grid_quadrants_x
        var y_index: int = floor(i / grid_quadrants_x)
        var z_offset: float = 0.1
        var cell_position: Vector3 = origin + Vector3(x_index * grid_quadrants_size, z_offset, y_index * grid_quadrants_size)
        var cell_transform: Transform3D = Transform3D.IDENTITY
        cell_transform.origin = cell_position

        # add new cell
        var new_cell: Cell = Cell.new(grid_quadrants_size, cell_position, i)
        grid_cells.append(new_cell)

        #multimesh.set_instance_transform(i, cell_transform)
        #multimesh.set_instance_color(i, available_color)


func _ready() -> void:
    Cell.available_color = available_color
    Cell.selected_color = selected_color
    Cell.invalid_color = invalid_placement_color

    # Create grid multimesh
    assert(is_instance_valid(grid_mesh))
    assert(is_instance_valid(grid_material))

    grid_mesh.surface_set_material(0, grid_material)

    var scenario: RID = get_world_3d().scenario
    multimesh_rid = RenderingServer.multimesh_create()
    grid_instance_rid = RenderingServer.instance_create()

    RenderingServer.multimesh_set_mesh(multimesh_rid, grid_mesh.get_rid())
    var cell_count: int = grid_quadrants_x * grid_quadrants_y
    RenderingServer.multimesh_allocate_data(multimesh_rid, cell_count, RenderingServer.MULTIMESH_TRANSFORM_3D, true, false, false)

    RenderingServer.instance_set_base(grid_instance_rid, multimesh_rid)
    RenderingServer.instance_set_scenario(grid_instance_rid, scenario)

    # Place quadrants on landscape surface
    generate_test_grid()

    _update_multimesh_buffer()


func _exit_tree() -> void:
    if multimesh_rid.is_valid():
        RenderingServer.free_rid(multimesh_rid)
    
    if grid_instance_rid.is_valid():
        RenderingServer.free_rid(grid_instance_rid)


func _update_multimesh_buffer() -> void:
    assert(multimesh_rid.is_valid())

    var new_buffer: PackedFloat32Array = PackedFloat32Array()
    for cell in grid_cells:
        new_buffer += cell.buffer
    
    RenderingServer.multimesh_set_buffer(multimesh_rid, new_buffer)


func _process(delta: float) -> void:
    # Pass cursor position to shader
    #grid_instance_mesh.material_override.set_shader_parameter("cursor_position", cursor_position);
    grid_material.set_shader_parameter("cursor_position", cursor_position);
    # Update cell color based on cursor position
    for cell in grid_cells:
        if cell.test_cursor_position(cursor_position):
            _update_multimesh_buffer()
