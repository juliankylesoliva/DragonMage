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
    [HideInInspector] public PlayerDamage damage;
    [HideInInspector] public PlayerInteraction interaction;
    [HideInInspector] public PlayerAnimation animationCtrl;
    [HideInInspector] public PlayerSpriteTrail spriteTrail;
    [HideInInspector] public PlayerEffects effects;
    [HideInInspector] public AudioPlayer sfxCtrl;

    [HideInInspector] public Rigidbody2D rb2d;
    [HideInInspector] public SpriteRenderer charSprite;

    /* INPUT ACTIONS */
    [Header("Input Actions")]
    [SerializeField] private InputAction moveAction;
    [SerializeField] private InputAction jumpAction;
    [SerializeField] private InputAction technicalAction;
    [SerializeField] private InputAction attackAction;
    [SerializeField] private InputAction formChangeAction;
    [SerializeField] private InputAction interactAction;

    /* INPUT VARIABLES */
    public bool areControlsFrozen { get; private set; }
    public Vector2 inputVector { get; private set; }
    public bool jumpButtonDown { get; private set; }
    public bool jumpButtonHeld { get; private set; }
    public bool technicalButtonHeld { get; private set; }
    public bool attackButtonDown { get; private set; }
    public bool attackButtonHeld { get; private set; }
    public bool formChangeButtonDown { get; private set; }
    public bool interactButtonDown { get; private set; }

    void OnEnable()
    {
        moveAction.Enable();
        jumpAction.Enable();
        technicalAction.Enable();
        attackAction.Enable();
        formChangeAction.Enable();
        interactAction.Enable();
    }

    void OnDisable()
    {
        moveAction.Disable();
        jumpAction.Disable();
        technicalAction.Disable();
        attackAction.Disable();
        formChangeAction.Disable();
        interactAction.Disable();
    }

    void Awake()
    {
        collisions = this.gameObject.GetComponent<PlayerCollisions>();
        buffers = this.gameObject.GetComponent<PlayerBuffers>();
        movement = this.gameObject.GetComponent<PlayerMovement>();
        jumping = this.gameObject.GetComponent<PlayerJumping>();
        temper = this.gameObject.GetComponent<PlayerTemper>();
        form = this.gameObject.GetComponent<PlayerForm>();
        interaction = this.gameObject.GetComponent<PlayerInteraction>();
        attacks = this.gameObject.GetComponent<PlayerAttacks>();
        damage = this.gameObject.GetComponent<PlayerDamage>();
        animationCtrl = this.gameObject.GetComponent<PlayerAnimation>();
        spriteTrail = this.gameObject.GetComponent<PlayerSpriteTrail>();
        effects = this.gameObject.GetComponent<PlayerEffects>();
        sfxCtrl = this.gameObject.GetComponent<AudioPlayer>();

        rb2d = this.gameObject.GetComponent<Rigidbody2D>();
        charSprite = this.gameObject.GetComponent<SpriteRenderer>();
        
        stateMachine = new StateMachine(this);
        stateMachine.Initialize(stateMachine.standingState);
        
        jumpAction.started += ctx => { jumpButtonDown = !areControlsFrozen; jumpButtonHeld = !areControlsFrozen; };
        jumpAction.canceled += ctx => { jumpButtonHeld = false; };

        technicalAction.started += ctx => { technicalButtonHeld = !areControlsFrozen; };
        technicalAction.canceled += ctx => { technicalButtonHeld = false; };

        attackAction.started += ctx => { attackButtonDown = !areControlsFrozen; attackButtonHeld = !areControlsFrozen; };
        attackAction.canceled += ctx => { attackButtonHeld = false; };

        formChangeAction.started += ctx => { formChangeButtonDown = !areControlsFrozen; };

        interactAction.started += ctx => { interactButtonDown = !areControlsFrozen; };
    }

    void Update()
    {
        inputVector = (!areControlsFrozen ? moveAction.ReadValue<Vector2>() : Vector2.zero);
        stateMachine.Update();
    }

    void LateUpdate()
    {
        if (jumpButtonDown) { jumpButtonDown = false; }
        if (attackButtonDown) { attackButtonDown = false; }
        if (formChangeButtonDown) { formChangeButtonDown = false; }
        if (interactButtonDown) { interactButtonDown = false; }
    }

    public void FreezeControls()
    {
        if (!areControlsFrozen && stateMachine.CurrentState != stateMachine.frozenControlState) { areControlsFrozen = true; stateMachine.TransitionTo(stateMachine.frozenControlState); }
    }

    public void UnfreezeControls()
    {
        areControlsFrozen = false;
    }
}
