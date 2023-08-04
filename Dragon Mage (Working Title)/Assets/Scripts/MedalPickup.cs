using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MedalPickup : MonoBehaviour
{
    Animator animator;
    Rigidbody2D rb2d;

    [SerializeField] float nonNeutralRatio = 2f;
    [SerializeField] float pickupVerticalVelocity = 5f;
    [SerializeField] float pickupGravityScale = 2f;
    [SerializeField] float pickupAnimationSpeed = 2f;
    [SerializeField] float pickupExpireTime = 0.5f;

    private bool isNotBlank = false;
    private bool isPickedUp = false;
    private bool isBeingDestroyed = false;

    void Awake()
    {
        animator = this.gameObject.GetComponent<Animator>();
        rb2d = this.gameObject.GetComponent<Rigidbody2D>();
    }

    void Update()
    {
        if (MedalFragment.totalFragments >= Level.FragmentsNeededForMedal)
        {
            isNotBlank = true;
            if (MedalFragment.dragonFragments == 0 || (MedalFragment.mageFragments / MedalFragment.dragonFragments) >= nonNeutralRatio)
            {
                animator.Play("MagicSpin");
            }
            else if (MedalFragment.mageFragments == 0 || (MedalFragment.dragonFragments / MedalFragment.mageFragments) >= nonNeutralRatio)
            {
                animator.Play("DragonSpin");
            }
            else
            {
                animator.Play("NeutralSpin");
            }
        }
        else
        {
            isNotBlank = false;
            animator.Play("BlankSpin");
        }
    }

    private IEnumerator DestroySelf()
    {
        if (!isPickedUp || isBeingDestroyed) { yield break; }
        isBeingDestroyed = true;
        yield return new WaitForSeconds(pickupExpireTime);
        GameObject.Destroy(this.gameObject);
    }

    void OnTriggerEnter2D(Collider2D other)
    {
        if (!isBeingDestroyed && isNotBlank && !isPickedUp && other.gameObject.tag == "Player")
        {
            isPickedUp = true;
            SoundFactory.SpawnSound("object_medal_pickup", this.transform.position);
            rb2d.constraints = RigidbodyConstraints2D.None;
            rb2d.gravityScale = pickupGravityScale;
            rb2d.velocity = (Vector2.up * pickupVerticalVelocity);
            animator.speed = pickupAnimationSpeed;
            StartCoroutine(DestroySelf());
        }
    }
}
