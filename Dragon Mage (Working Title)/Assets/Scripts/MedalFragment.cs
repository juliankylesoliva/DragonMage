using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MedalFragment : MonoBehaviour
{
    public static int totalFragments { get { return (mageFragments + dragonFragments); } }
    public static int mageFragments { get; private set; }
    public static int dragonFragments { get; private set; }

    public static int droppedMageFragments { get; private set; }
    public static int droppedDragonFragments { get; private set; }

    private const int MAX_FRAGMENTS_DROPPED = 10;
    private const int BASE_FRAGMENT_DROP_SPLIT = 5;
    private const int MIN_FRAGMENT_DROP_SPLIT_MODIFER = -5;
    private const int MAX_FRAGMENT_DROP_SPLIT_MODIFER = 5;

    void OnTriggerEnter2D(Collider2D other)
    {
        if (other.gameObject.tag == "Player")
        {
            PlayerCtrl playerRef = other.gameObject.GetComponent<PlayerCtrl>();
            if (playerRef != null && !playerRef.damage.isPlayerDamaged)
            {
                if (playerRef.form.currentMode == CharacterMode.MAGE)
                {
                    mageFragments++;
                }
                else
                {
                    dragonFragments++;
                }

                GameObject tempObj = EffectFactory.SpawnEffect("FragmentGrab", this.transform.position);
                FragmentGrab tempFragGrab = tempObj.GetComponent<FragmentGrab>();
                tempFragGrab.Setup(playerRef.form.currentMode);

                SoundFactory.SpawnSound("object_fragment_pickup", this.transform.position);
                this.gameObject.SetActive(false);
            }
        }
    }

    public static void ResetFragments()
    {
        mageFragments = 0;
        dragonFragments = 0;
    }

    public static void DropFragments()
    {
        if (totalFragments > 0)
        {
            if (totalFragments <= MAX_FRAGMENTS_DROPPED)
            {
                droppedMageFragments = mageFragments;
                droppedDragonFragments = dragonFragments;

                mageFragments = 0;
                dragonFragments = 0;
            }
            else
            {
                if (mageFragments == 0)
                {
                    dragonFragments -= MAX_FRAGMENTS_DROPPED;
                    droppedDragonFragments = MAX_FRAGMENTS_DROPPED;
                }
                else if (dragonFragments == 0)
                {
                    mageFragments -= MAX_FRAGMENTS_DROPPED;
                    droppedMageFragments = MAX_FRAGMENTS_DROPPED;
                }
                else
                {
                    int mageFragmentsToDrop = BASE_FRAGMENT_DROP_SPLIT;
                    int dragonFragmentsToDrop = BASE_FRAGMENT_DROP_SPLIT;

                    int fragmentDifference = (mageFragments - dragonFragments);
                    if (fragmentDifference != 0)
                    {
                        fragmentDifference = Mathf.Min(Mathf.Max(fragmentDifference, MIN_FRAGMENT_DROP_SPLIT_MODIFER), MAX_FRAGMENT_DROP_SPLIT_MODIFER);
                        mageFragmentsToDrop += fragmentDifference;
                        dragonFragmentsToDrop -= fragmentDifference;

                        if (mageFragmentsToDrop > mageFragments)
                        {
                            mageFragmentsToDrop = mageFragments;
                            dragonFragmentsToDrop = (MAX_FRAGMENTS_DROPPED - mageFragmentsToDrop);
                        }
                        else if (dragonFragmentsToDrop > dragonFragments)
                        {
                            dragonFragmentsToDrop = dragonFragments;
                            mageFragmentsToDrop = (MAX_FRAGMENTS_DROPPED - dragonFragmentsToDrop);
                        }
                        else { /* Nothing */ }
                    }

                    mageFragments -= mageFragmentsToDrop;
                    dragonFragments -= dragonFragmentsToDrop;

                    droppedMageFragments = mageFragmentsToDrop;
                    droppedDragonFragments = dragonFragmentsToDrop;
                }
            }
        }
        else
        {
            droppedMageFragments = 0;
            droppedDragonFragments = 0;
        }
    }
}
