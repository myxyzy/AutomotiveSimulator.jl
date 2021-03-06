@testset "action interface" begin
    roadway = get_test_roadway()
    trajdata = get_test_trajdata(roadway)
    veh = trajdata[1][1]
    s = VehicleState()
    @test VehicleState() == propagate(veh, s, roadway, NaN)
end

@testset "AccelTurnrate" begin
    roadway = get_test_roadway()
    trajdata = get_test_trajdata(roadway)
    veh = trajdata[1][1]
    a = AccelTurnrate(0.1,0.2)
    io = IOBuffer()
    show(io, a)
    close(io)
    @test a == convert(AccelTurnrate, [0.1,0.2])
    @test copyto!([NaN, NaN], AccelTurnrate(0.1,0.2)) == [0.1,0.2]
    @test length(AccelTurnrate) == 2

    s = propagate(veh, AccelTurnrate(0.0,0.0), roadway, 1.0)
    @test isapprox(s.posG.x, veh.state.v)
    @test isapprox(s.posG.y, 0.0)
    @test isapprox(s.posG.θ, 0.0)

    # TODO Test the get method
end

@testset "AccelDesang" begin
    roadway = get_test_roadway()
    trajdata = get_test_trajdata(roadway)
    veh = trajdata[1][1]
    a = AccelDesang(0.1,0.2)
    @test a == convert(AccelDesang, [0.1,0.2])
    @test copyto!([NaN, NaN], AccelDesang(0.1,0.2)) == [0.1,0.2]
    @test length(AccelDesang) == 2

    io = IOBuffer()
    show(io, a)

    s = propagate(veh, AccelDesang(0.0,0.0), roadway, 1.0)
    @test isapprox(s.posG.x, veh.state.v*1.0)
    @test isapprox(s.posG.y, 0.0)
    @test isapprox(s.posG.θ, 0.0)
    @test isapprox(s.v, veh.state.v)
end

@testset "AccelSteeringAngle" begin
    roadway = get_test_roadway()
    trajdata = get_test_trajdata(roadway)
    veh = trajdata[1][1]
    a = AccelSteeringAngle(0.1,0.2)
    io = IOBuffer()
    show(io, a)
    close(io)
    @test a == convert(AccelSteeringAngle, [0.1,0.2])
    @test copyto!([NaN, NaN], AccelSteeringAngle(0.1,0.2)) == [0.1,0.2]
    @test length(AccelSteeringAngle) == 2

    # Check that propagate
    # won't work with the veh type loaded from test_tra
    @test_throws ErrorException propagate(veh, AccelSteeringAngle(0.0,0.0), roadway, 1.0)

    veh = Entity(veh.state, BicycleModel(veh.def), veh.id)
    s = propagate(veh, AccelSteeringAngle(0.0,0.0), roadway, 1.0)
    @test isapprox(s.posG.x, veh.state.v*1.0)
    @test isapprox(s.posG.y, 0.0)
    @test isapprox(s.posG.θ, 0.0)
    @test isapprox(s.v, veh.state.v)
    # Test the branch condition within propagate
    s = propagate(veh, AccelSteeringAngle(0.0,1.0), roadway, 1.0)
    @test isapprox(s.v, veh.state.v)
end

@testset "LaneFollowingAccel" begin 
    a = LaneFollowingAccel(1.0)
    roadway = gen_straight_roadway(3, 100.0)
    s = VehicleState(VecSE2(0.0, 0.0, 0.0), roadway, 0.0)
    veh = Entity(s, VehicleDef(), 1)
    vehp = propagate(veh, a, roadway, 1.0)
    @test posf(vehp).s == 0.5
end

@testset "LatLonAccel" begin
    roadway = get_test_roadway()
    trajdata = get_test_trajdata(roadway)
    veh = trajdata[1][1]
    a = LatLonAccel(0.1,0.2)
    io = IOBuffer()
    show(io, a)
    close(io)
    @test a == convert(LatLonAccel, [0.1,0.2])
    @test copyto!([NaN, NaN], LatLonAccel(0.1,0.2)) == [0.1,0.2]
    @test length(LatLonAccel) == 2

    Δt = 0.1
    s = propagate(veh, LatLonAccel(0.0,0.0), roadway, Δt)
    @test isapprox(s.posG.x, veh.state.v*Δt)
    @test isapprox(s.posG.y, 0.0)
    @test isapprox(s.posG.θ, 0.0)
    @test isapprox(s.v, veh.state.v)
end

@testset "Pedestrian LatLon" begin
    roadway = get_test_roadway()
    trajdata = get_test_trajdata(roadway)
    veh = trajdata[1][1]
    a = PedestrianLatLonAccel(0.5,1.0, roadway[LaneTag(2,1)])
    Δt = 1.0
    s = propagate(veh, a, roadway, Δt)
    @test s.posF.roadind.tag == LaneTag(2,1)
    @test isapprox(s.posG.x, 4.0)
    @test isapprox(s.posG.y, 0.25) 
end

@testset "Action Mapping" begin
    a1 = LaneFollowingAccel(1.2)
    a2 = LaneFollowingAccel(.4)
    a3 = LaneFollowingAccel(0.)
    actions = [a1, a2, a3]
    ids = [:vehA, :vehB, :vehC]
    action_mappings = Scene([EntityAction(a, id) for (a,id) in zip(actions, ids)])
    for (action,id) in zip(actions, ids)
        @test get_by_id(action_mappings, id).action.a == action.a
    end
end
