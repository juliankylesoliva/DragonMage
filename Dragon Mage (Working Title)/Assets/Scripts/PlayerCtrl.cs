using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerCtrl : MonoBehaviour
{
    /* COMPONENTS */
    [HideInInspector] public StateMachine stateMachine;
    [HideInInspector] public PlayerCollisions collisions;
    [HideInInspector] public PlayerBuffers buffers;
    [HideInInspector] public PlayerMovement movement;
    [HideInInspector] public PlayerJumping jumping;
    [HideInInspector] public PlayerTemper temper;
    [HideInInspector] public PlayerForm form;
    [HideInInspector] public PlayerAttacks attacks;
    [HideInInspector] public PlayerAnimation animationCtrl;
    [HideInInspector] public PlayerSpriteTrail spriteTrail;
    [HideInInspector] public AudioPlayer sfxCtrl;

    [HideInInspector] public Rigidbody2D rb2d;
    [HideInInspector] public SpriteRenderer charSprite;

    /* INPUT ACTIONS */
    [Header("Input Actions")]
    [SerializeField] private InputAction moveAction;
    [SerializeField] private InputAction jumpAction;
    [SerializeField] private InputAction instantGlideAction;
    [SerializeField] private InputAction attackAction;
    [SerializeField] private InputAction formChangeAction;

    /* INPUT VARIABLES */
    public Vector2 inputVector { get; private set; }
    public bool jumpButtonDown { get; private set; }
    public bool jumpButtonHeld { get; private set; }
    public bool instantGlideButtonHeld { get; private set; }
    public bool attackButtonDown { get; private set; }
    public bool attackButtonHeld { get; private set; }
    public bool formChangeButtonDown { get; private set; }

    void OnEnable()
    {
        moveAction.Enable();
        jumpAction.Enable();
        instantGlideAction.Enable();
        attackAction.Enable();
        formChangeAction.Enable();
    }

    void OnDisable()
    {
        moveAction.Disable();
        jumpAction.Disable();
        instantGlideAction.Disable();
        attackAction.Disable();
        formChangeAction.Disable();
    }

    void Awake()
    {
        collisions = this.gameObject.GetComponent<PlayerCollisions>();
        buffers = this.gameObject.GetComponent<PlayerBuffers>();
        movement = this.gameObject.GetComponent<PlayerMovement>();
        jumping = this.gameObject.GetComponent<PlayerJumping>();
        temper = this.gameObject.GetComponent<PlayerTemper>();
        form = this.gameObject.GetComponent<PlayerForm>();
        attacks = this.gameObject.GetComponent<PlayerAttacks>();
        animationCtrl = this.gameObject.GetComponent<PlayerAnimation>();
        spriteTrail = this.gameObject.GetComponent<PlayerSpriteTrail>();
        sfxCtrl = this.gameObject.GetComponent<AudioPlayer>();

        rb2d = this.gameObject.GetComponent<Rigidbody2D>();
        charSprite = this.gameObject.GetComponent<SpriteRenderer>();
        
        stateMachine = new StateMachine(this);
        stateMachine.Initialize(stateMachine.standingState);

        jumpAction.started += ctx => { jumpButtonDown = true; jumpButtonHeld = true; };
        jumpAction.canceled += ctx => { jumpButtonHeld = false; };

        instantGlideAction.started += ctx => { instantGlideButtonHeld = true; };
        instantGlideAction.canceled += ctx => { instantGlideButtonHeld = false; };

        attackAction.started += ctx => { attackButtonDown = true; attackButtonHeld = true; };
        attackAction.canceled += ctx => { attackButtonHeld = false; };

        formChangeAction.started += ctx => { formChangeButtonDown = true; };
    }

    void Update()
    {
        inputVector = moveAction.ReadValue<Vector2>();
        stateMachine.Update();
    }

    void LateUpdate()
    {
        if (jumpButtonDown) { jumpButtonDown = false; }
        if (attackButtonDown) { attackButtonDown = false; }
        if (formChangeButtonDown) { formChangeButtonDown = false; }
    }
}
