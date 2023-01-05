using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MagicBlast : MonoBehaviour
{
    /* COMPONENTS */
    Rigidbody2D rb2d;

    /* DRAG AND DROP */
    [SerializeField] GameObject blastHitboxPrefab;

    /* EDITOR VARIABLES */
    [SerializeField] SpriteRenderer spriteRenderer;
    [SerializeField] Color chargedColor;
    [SerializeField] float chargeMultiplier = 2f;
    [SerializeField] float fuseTime = 3f;
    [SerializeField] float verticalLaunchSpeed = 1f;
    [SerializeField] float horizontalLaunchSpeed = 2f;
    [SerializeField] float rotationSpeed = 10f;
    [SerializeField] float blastDuration = 0.1f;
    [SerializeField] float blastStrength = 3f;
    [SerializeField] float blastRadius = 1.5f;

    /* SCRIPT VARIABLES */
    private bool isCharged = false;
    private float fuseTimeLeft = 0f;

    void Awake()
    {
        rb2d = this.gameObject.GetComponent<Rigidbody2D>();
    }

    void Start()
    {
        fuseTimeLeft = fuseTime;
    }

    void Update()
    {
        fuseTimeLeft -= Time.deltaTime;
        if (fuseTimeLeft <= 0f)
        {
            Detonate();
        }
    }

    public void Detonate()
    {
        GameObject tempObj = Instantiate(blastHitboxPrefab, this.transform.position, Quaternion.identity);
        BlastHitbox tempBlast = tempObj.GetComponent<BlastHitbox>();
        tempBlast.Setup(blastDuration * (isCharged ? chargeMultiplier : 1f), blastStrength * (isCharged ? chargeMultiplier : 1f), blastRadius * (isCharged ? chargeMultiplier : 1f));
        GameObject.Destroy(this.gameObject);
    }

    public void Setup(bool isGoingRight = true, float horizontalVelocity = 0f, float verticalAxis = 0f)
    {
        rb2d.velocity = new Vector2((isGoingRight ? horizontalLaunchSpeed : -horizontalLaunchSpeed) * (verticalAxis != 0f ? 0.25f : 1f) + (horizontalVelocity * 0.5f), verticalLaunchSpeed * (verticalAxis > 0f ? 2f : 1f) * (verticalAxis < 0f ? -0.5f : 1f));
        rb2d.AddTorque(rotationSpeed * (isGoingRight ? -1f : 1f) * (verticalAxis != 0f ? 0.5f : 1f));
    }

    public void AddChargedState()
    {
        isCharged = true;
        spriteRenderer.color = chargedColor;
    }
}
