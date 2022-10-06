using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "PlayerCtrlProperties", menuName = "ScriptableObjects/PlayerCtrlProperties", order = 1)]
public class PlayerCtrlProperties : ScriptableObject
{
    /* RUNNING VARIABLES */
    [Header("Running Variables")]
    [SerializeField, Range(0.01f, 1f)] float _acceleration = 0.5f;
    public float acceleration { get { return _acceleration; } }

    [SerializeField, Range(0.01f, 1f)] float _deceleration = 0.5f;
    public float deceleration { get { return _deceleration; } }

    [SerializeField, Range(2f, 20f)] float _topSpeed = 18f;
    public float topSpeed { get { return _topSpeed; } }

    [SerializeField, Range(0.01f, 1f)] float _turningSpeed = 0.5f;
    public float turningSpeed { get { return _turningSpeed; } }

    /* JUMPING VARIABLES */
    [Header("Jumping Variables")]
    [SerializeField, Range(2f, 12f)] float _jumpSpeed = 4f;
    public float jumpSpeed { get { return _jumpSpeed; } }

    [SerializeField, Range(0.1f, 10f)] float _risingGravity = 1f;
    public float risingGravity { get { return _risingGravity; } }

    [SerializeField, Range(0.1f, 10f)] float _fallingGravity = 1f;
    public float fallingGravity { get { return _fallingGravity; } }

    [SerializeField, Range(2f, 20f)] float _fallSpeed = 6f;
    public float fallSpeed { get { return _fallSpeed; } }

    [SerializeField, Range(0.01f, 1f)] float _airAcceleration = 0.5f;
    public float airAcceleration { get { return _airAcceleration; } }

    [SerializeField, Range(0.01f, 1f)] float _airDeceleration = 0.5f;
    public float airDeceleration { get { return _airDeceleration; } }

    [SerializeField, Range(0.01f, 1f)] float _airTurningSpeed = 0.5f;
    public float airTurningSpeed { get { return _airTurningSpeed; } }

    [Header("Variable Jump Variables")]
    [SerializeField] bool _enableVariableJumps = true;
    public bool enableVariableJumps { get { return _enableVariableJumps; } }

    [SerializeField, Range(0f, 10f)] float _variableJumpDecay = 0.5f;
    public float variableJumpDecay { get { return _variableJumpDecay; } }

    [Header("Air Stalling Variables")]
    [SerializeField] bool _enableAirStalling = true;
    public bool enableAirStalling { get { return _enableAirStalling; } }

    [SerializeField, Range(0f, 1f)] float _airStallSpeed = 1f;
    public float airStallSpeed { get { return _airStallSpeed; } }

    [SerializeField, Range(0f, 5f)] float _maxAirStallTime = 3f;
    public float maxAirStallTime { get { return _maxAirStallTime; } }

    [Header("Midair Jump Variables")]
    [SerializeField, Range(0, 5)] int _maxMidairJumps = 3;
    public int maxMidairJumps { get { return _maxMidairJumps; } }

    [SerializeField, Range(2f, 12f)] float _midairJumpSpeed = 4.25f;
    public float midairJumpSpeed { get { return _midairJumpSpeed; } }
}
