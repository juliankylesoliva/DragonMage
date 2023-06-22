using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum MedalType { BLANK, NEUTRAL, MAGIC, DRAGON }

public class MedalPickup : MonoBehaviour
{
    Animator animator;

    [SerializeField] float nonNeutralRatio = 2f;

    void Awake()
    {
        animator = this.gameObject.GetComponent<Animator>();
    }

    void Update()
    {
        if (MedalFragment.totalFragments >= Level.FragmentsNeededForMedal)
        {
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
            animator.Play("BlankSpin");
        }
    }

    void OnTriggerEnter2D(Collider2D other)
    {
        if (other.gameObject.tag == "Player")
        {
            GameObject.Destroy(this.gameObject);
        }
    }
}
