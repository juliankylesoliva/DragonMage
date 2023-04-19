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
    [SerializeField] Color defaultColor;
    [SerializeField] Color pulseColor;
    [SerializeField] float fuseTime = 3f;
    [SerializeField] float verticalLaunchSpeed = 1f;
    [SerializeField] float horizontalLaunchSpeed = 2f;
    [SerializeField] float rotationSpeed = 10f;
    [SerializeField] float blastDuration = 0.1f;
    [SerializeField] float blastStrength = 3f;
    [SerializeField] float blastRadius = 1.5f;

    /* SCRIPT VARIABLES */
    private PlayerTemper temper;
    private float fuseTimeLeft = 0f;
    private float currentLerpValue = 0f;

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
        spriteRenderer.color = Color.Lerp(defaultColor, pulseColor, Mathf.PingPong(currentLerpValue, 1f));
        fuseTimeLeft -= Time.deltaTime;
        currentLerpValue += ((fuseTime / fuseTimeLeft) * Time.deltaTime);
        if (fuseTimeLeft <= 0f)
        {
            Detonate();
        }
    }

    public void Detonate()
    {
        GameObject tempEffect = EffectFactory.SpawnEffect("MagicExplosion", this.transform.position);
        tempEffect.transform.localScale = new Vector3(blastRadius / 0.5f, blastRadius / 0.5f, 1f);
        GameObject tempObj = Instantiate(blastHitboxPrefab, this.transform.position, Quaternion.identity);
        BlastHitbox tempBlast = tempObj.GetComponent<BlastHitbox>();
        tempBlast.Setup(temper, blastDuration, blastStrength, blastRadius);
        GameObject.Destroy(this.gameObject);
    }

    public void Setup(PlayerTemper temper, bool isGoingRight = true, float horizontalVelocity = 0f, float verticalAxis = 0f)
    {
        this.temper = temper;
        rb2d.velocity = new Vector2((isGoingRight ? horizontalLaunchSpeed : -horizontalLaunchSpeed) * (verticalAxis != 0f ? 0.25f : 1f) + (horizontalVelocity * 0.5f), verticalLaunchSpeed * (verticalAxis > 0f ? 2.5f : 1f) * (verticalAxis < 0f ? -0.5f : 1f));
        rb2d.AddTorque(rotationSpeed * (isGoingRight ? -1f : 1f) * (verticalAxis != 0f ? 0.5f : 1f));
    }
}
