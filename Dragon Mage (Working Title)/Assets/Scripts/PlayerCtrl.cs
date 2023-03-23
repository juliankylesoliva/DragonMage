using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerCtrl : MonoBehaviour
{
    /* COMPONENTS */
    public StateMachine stateMachine;
    [HideInInspector] public PlayerCollisions collisions;
    [HideInInspector] public PlayerBuffers buffers;
    [HideInInspector] public PlayerMovement movement;
    [HideInInspector] public PlayerJumping jumping;
    [HideInInspector] public PlayerTemper temper;
    [HideInInspector] public PlayerForm form;
    [HideInInspector] public PlayerAttacks attacks;
    [HideInInspector] public PlayerAnimation animationCtrl;

    [HideInInspector] public Rigidbody2D rb2d;
    [HideInInspector] public SpriteRenderer charSprite;

    /* DRAG AND DROP */
    [Header("Drag and Drop")]
    public Sprite tempMageSprite;
    public Sprite tempDragonSprite;

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

        rb2d = this.gameObject.GetComponent<Rigidbody2D>();
        charSprite = this.gameObject.GetComponent<SpriteRenderer>();
        
        stateMachine = new StateMachine(this);
        stateMachine.Initialize(stateMachine.standingState);
    }

    void Update()
    {
        stateMachine.Update();
    }
}
