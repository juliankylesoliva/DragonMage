using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MedalFragment : MonoBehaviour
{
    public static int totalFragments { get { return (mageFragments + dragonFragments); } }
    public static int mageFragments { get; private set; }
    public static int dragonFragments { get; private set; }

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
    
    public static void DropFragments(int mage, int dragon)
    {
        mageFragments -= mage;
        dragonFragments -= dragon;
    }
}
