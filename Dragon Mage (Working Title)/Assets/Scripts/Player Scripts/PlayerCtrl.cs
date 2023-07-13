using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerCtrl : MonoBehaviour
{
    /* COMPONENTS */
    [HideInInspector] public StateMachine stateMachine;
    [HideInInspector] public PlayerCollisions collisions;
    [HideInInspector] public PlayerBuffers buffers;
    [HideInInspector] public PlayerMovement movement;
    [HideInInspector] public PlayerJumping jumping;
    [HideInInspector] public PlayerAttacks attacks;
    [HideInInspector] public PlayerTemper temper;
    [HideInInspector] public PlayerForm form;
    [HideInInspector] public PlayerDamage damage;
    [HideInInspector] public PlayerInteraction interaction;
    [HideInInspector] public PlayerAnimation animationCtrl;
    [HideInInspector] public PlayerSpriteTrail spriteTrail;
    [HideInInspector] public PlayerEffects effects;
    [HideInInspector] public AudioPlayer sfxCtrl;

    [HideInInspector] public Rigidbody2D rb2d;
    [HideInInspector] public SpriteRenderer charSprite;

    /* INPUT VARIABLES */
    public bool areControlsFrozen { get; private set; }
    public Vector2 inputVector { get; private set; }
    public bool jumpButtonDown { get; private set; }
    public bool jumpButtonHeld { get; private set; }
    public bool attackButtonDown { get; private set; }
    public bool attackButtonHeld { get; private set; }
    public bool technicalButtonHeld { get; private set; }
    public bool formChangeButtonDown { get; private set; }
    public bool interactButtonDown { get; private set; }

    void Awake()
    {
        collisions = this.gameObject.GetComponent<PlayerCollisions>();
        buffers = this.gameObject.GetComponent<PlayerBuffers>();
        movement = this.gameObject.GetComponent<PlayerMovement>();
        jumping = this.gameObject.GetComponent<PlayerJumping>();
        attacks = this.gameObject.GetComponent<PlayerAttacks>();
        temper = this.gameObject.GetComponent<PlayerTemper>();
        form = this.gameObject.GetComponent<PlayerForm>();
        interaction = this.gameObject.GetComponent<PlayerInteraction>();
        damage = this.gameObject.GetComponent<PlayerDamage>();
        animationCtrl = this.gameObject.GetComponent<PlayerAnimation>();
        spriteTrail = this.gameObject.GetComponent<PlayerSpriteTrail>();
        effects = this.gameObject.GetComponent<PlayerEffects>();
        sfxCtrl = this.gameObject.GetComponent<AudioPlayer>();

        rb2d = this.gameObject.GetComponent<Rigidbody2D>();
        charSprite = this.gameObject.GetComponent<SpriteRenderer>();
        
        stateMachine = new StateMachine(this);
        stateMachine.Initialize(stateMachine.standingState);
    }

    void Update()
    {
        if (!PauseHandler.isPaused)
        {
            inputVector = (!areControlsFrozen ? InputHub.inputVector : Vector2.zero);

            jumpButtonDown = InputHub.jumpButtonDown;
            jumpButtonHeld = (!areControlsFrozen && InputHub.jumpButtonHeld);

            attackButtonDown = InputHub.attackButtonDown;
            attackButtonHeld = (!areControlsFrozen && InputHub.attackButtonHeld);

            technicalButtonHeld = (!areControlsFrozen && InputHub.technicalButtonHeld);

            formChangeButtonDown = (!areControlsFrozen && InputHub.formChangeButtonDown);

            interactButtonDown = (!areControlsFrozen && InputHub.interactButtonDown);

            stateMachine.Update();
        }
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
